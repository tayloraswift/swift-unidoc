import CodelinkResolution
import Codelinks
import Doclinks
import ModuleGraphs
import Sources
import SymbolGraphs
import Unidoc
import UnidocDiagnostics
import UnidocRecords

struct DynamicResolver
{
    private
    let diagnostics:DynamicLinkerDiagnostics
    private
    let codelinks:CodelinkResolver<Unidoc.Scalar>
    private
    let context:DynamicContext

    private
    init(diagnostics:DynamicLinkerDiagnostics,
        codelinks:CodelinkResolver<Unidoc.Scalar>,
        context:DynamicContext)
    {
        self.diagnostics = diagnostics
        self.codelinks = codelinks
        self.context = context
    }
}
extension DynamicResolver
{
    init(context:DynamicContext,
        diagnostics:DynamicLinkerDiagnostics,
        namespace:ModuleIdentifier,
        clients:DynamicClientGroup,
        scope:[String] = [])
    {
        self.init(
            diagnostics: diagnostics,
            codelinks: .init(table: clients.codelinks, scope: .init(
                namespace: namespace,
                imports: clients.imports,
                path: scope)),
            context: context)
    }
}
extension DynamicResolver
{
    private
    var current:SnapshotObject { self.context.current }
}

extension DynamicResolver
{
    func link(article:SymbolGraph.Article) ->
    (
        overview:Record.Passage?,
        details:Record.Passage?
    )
    {
        let outlines:[Record.Outline] = article.outlines.map { self.expand($0) }

        let overview:Record.Passage? = article.overview.isEmpty ? nil : .init(
            outlines: .init(outlines.prefix(article.fold)),
            markdown: article.overview)
        let details:Record.Passage? = article.details.isEmpty ? nil : .init(
            outlines: .init(outlines.dropFirst(article.fold)),
            markdown: article.details)
        return (overview, details)
    }

    func link(topic:SymbolGraph.Topic) -> (overview:Record.Passage?, members:[Record.Link])
    {
        let overview:Record.Passage? = topic.overview.isEmpty ? nil : .init(
            outlines: topic.outlines.map { self.expand($0) },
            markdown: topic.overview)

        return (overview, topic.members.map { self.resolve($0) })
    }
}
extension DynamicResolver
{
    private
    func expand(_ outline:SymbolGraph.Outline) -> Record.Outline
    {
        var length:Int
        {
            var length:Int = 1
            for character:Character in outline.text where character == " "
            {
                length += 1
            }
            return length
        }

        switch outline.referent
        {
        case .scalar(let scalar):
            if      let _:Int = scalar / .decl,
                    let scalar:Unidoc.Scalar = self.current.scalars.decls[scalar]
            {
                return .path(outline.text, self.context.expand(scalar, to: length))
            }
            else if let _:Int = scalar / .article
            {
                return .path(outline.text, [self.current.zone + scalar])
            }
            else if let _:Int = scalar / .file
            {
                //  TODO: implement me
            }
            else if let namespace:Int = scalar / .module,
                    let scalar:Unidoc.Scalar = self.current.scalars.namespaces[namespace]
            {
                return .path(outline.text, [scalar])
            }

        case .vector(let feature, self: let heir):
            //  Only references to declarations can generate vectors. So we can assume
            //  both components are declaration scalars.
            if  let feature:Unidoc.Scalar = self.current.scalars.decls[feature],
                let heir:Unidoc.Scalar = self.current.scalars.decls[heir]
            {
                return .path(outline.text, self.context.expand((heir, feature), to: length))
            }

        case .unresolved(let location):
            switch self.resolve(outline.text, at: location)
            {
            case  nil:
                return .text(outline.text)

            case (let codelink, nil)?:
                return .text("\(codelink.path)")

            case (let codelink, .scalar(let scalar)?)?:
                return .path("\(codelink.path)", self.context.expand(scalar,
                    to: codelink.path.components.count))

            case (let codelink, .vector(let feature, self: let heir)?)?:
                return .path("\(codelink.path)", self.context.expand((heir, feature),
                    to: codelink.path.components.count))
            }
        }

        return .text("<unavailable>")
    }

    private
    func resolve(_ outline:SymbolGraph.Outline) -> Record.Link
    {
        switch outline.referent
        {
        case .scalar(let scalar):
            if      let _:Int = scalar / .decl,
                    let scalar:Unidoc.Scalar = self.current.scalars.decls[scalar]
            {
                return .scalar(scalar)
            }
            else if let namespace:Int = scalar / .module,
                    let scalar:Unidoc.Scalar = self.current.scalars.namespaces[namespace]
            {
                return .scalar(scalar)
            }
            else
            {
                //  The rest of the planes don’t cross packages... yet...
                return .scalar(self.current.zone + scalar)
            }

        case .vector(let feature, self: _):
            //  Only references to declarations can generate vectors. So we can assume
            //  both components are declaration scalars.
            if  let feature:Unidoc.Scalar = self.current.scalars.decls[feature]
            {
                return .scalar(feature)
            }

        case .unresolved(let location):
            switch self.resolve(outline.text, at: location)
            {
            case  nil:
                return .text(outline.text)

            case (let codelink, nil)?:
                return .text("\(codelink.path)")

            case (_, .scalar(let scalar)?)?:
                return .scalar(scalar)

            case (_, .vector(let feature, self: _)?)?:
                return .scalar(feature)
            }
        }

        return .text("<unavailable>")
    }

    private
    func resolve(_ expression:String, at location:SourceLocation<Int32>?) ->
    (
        codelink:Codelink,
        resolved:CodelinkResolver<Unidoc.Scalar>.Overload.Target?
    )?
    {
        var context:Diagnostic.Context<Unidoc.Scalar>
        {
            .init(location: location?.map { self.current.zone + $0 })
        }

        let codelink:Codelink?

        if  let doclink:Doclink = .init(expression)
        {
            codelink = .init(doclink.path.joined(separator: "/"))
        }
        else
        {
            codelink = .init(expression)
        }
        guard let codelink:Codelink
        else
        {
            //  Somehow, a symbolgraph was compiled with an unparseable codelink!
            self.diagnostics.errors.append(InvalidAutolinkError<Unidoc.Scalar>.init(
                expression: expression,
                context: context))
            return nil
        }

        switch self.codelinks.resolve(codelink)
        {
        case .some(let overloads):
            self.diagnostics.errors.append(InvalidCodelinkError<Unidoc.Scalar>.init(
                overloads: overloads,
                codelink: codelink,
                context: context))
            return (codelink, nil)

        case .one(let overload):
            return (codelink, overload.target)
        }
    }
}
