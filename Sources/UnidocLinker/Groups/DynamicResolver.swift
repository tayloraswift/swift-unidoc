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
    init(diagnostics:DynamicLinkerDiagnostics,
        namespace:ModuleIdentifier,
        global:DynamicContext,
        module:DynamicLinker.ModuleContext,
        scope:[String] = [])
    {
        self.init(
            diagnostics: diagnostics,
            codelinks: .init(table: module.codelinks, scope: .init(
                namespace: namespace,
                imports: module.imports,
                path: scope)),
            context: global)
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
        overview:Volume.Passage?,
        details:Volume.Passage?
    )
    {
        let outlines:[Volume.Outline] = article.outlines.map { self.expand($0) }

        let overview:Volume.Passage? = article.overview.isEmpty ? nil : .init(
            outlines: .init(outlines[..<article.fold]),
            markdown: article.overview)
        let details:Volume.Passage? = article.details.isEmpty ? nil : .init(
            outlines: .init(outlines[article.fold...]),
            markdown: article.details)
        return (overview, details)
    }

    func link(topic:SymbolGraph.Topic) -> (overview:Volume.Passage?, members:[Volume.Link])
    {
        let overview:Volume.Passage? = topic.overview.isEmpty ? nil : .init(
            outlines: topic.outlines.map { self.expand($0) },
            markdown: topic.overview)

        return (overview, topic.members.map { self.resolve($0) })
    }
}
extension DynamicResolver
{
    private
    func expand(_ outline:SymbolGraph.Outline) -> Volume.Outline
    {
        func words(in text:String) -> Int
        {
            var length:Int = 1
            for character:Character in text where character == " "
            {
                length += 1
            }
            return length
        }

        switch outline
        {
        case    .scalar(let scalar, text: let text):
            if      let _:Int = scalar / .decl,
                    let scalar:Unidoc.Scalar = self.current.scalars.decls[scalar]
            {
                return .path(text, self.context.expand(scalar, to: words(in: text)))
            }
            else if let _:Int = scalar / .article
            {
                return .path(text, [self.current.edition + scalar])
            }
            else if let _:Int = scalar / .file
            {
                //  TODO: implement me
            }
            else if let namespace:Int = scalar / .module,
                    let scalar:Unidoc.Scalar = self.current.scalars.namespaces[namespace]
            {
                return .path(text, [scalar])
            }

        case    .vector(let feature, self: let heir, text: let text):
            //  Only references to declarations can generate vectors. So we can assume
            //  both components are declaration scalars.
            if  let feature:Unidoc.Scalar = self.current.scalars.decls[feature],
                let heir:Unidoc.Scalar = self.current.scalars.decls[heir]
            {
                return .path(text, self.context.expand((heir, feature), to: words(in: text)))
            }

        case    .codelink(let expression, let location):
            switch self.resolve(expression, at: location)
            {
            case  nil:
                return .text(expression)

            case (let codelink, nil)?:
                return .text("\(codelink.path)")

            case (let codelink, .scalar(let scalar)?)?:
                return .path("\(codelink.path)", self.context.expand(scalar,
                    to: codelink.path.components.count))

            case (let codelink, .vector(let feature, self: let heir)?)?:
                return .path("\(codelink.path)", self.context.expand((heir, feature),
                    to: codelink.path.components.count))
            }
        case    .doclink(let expression, let location):
            switch self.resolve(expression, at: location)
            {
            case  nil:
                return .text(expression)

            case (_, nil)?:
                return .text(expression)

            case (let codelink, .scalar(let scalar)?)?:
                return .path(expression, self.context.expand(scalar,
                    to: codelink.path.components.count))

            case (let codelink, .vector(let feature, self: let heir)?)?:
                return .path(expression, self.context.expand((heir, feature),
                    to: codelink.path.components.count))
            }
        }

        return .text("<unavailable>")
    }

    private
    func resolve(_ outline:SymbolGraph.Outline) -> Volume.Link
    {
        switch outline
        {
        case   .scalar(let scalar, text: _):
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
                return .scalar(self.current.edition + scalar)
            }
        case    .vector(let feature, self: _, text: _):
            //  Only references to declarations can generate vectors. So we can assume
            //  both components are declaration scalars.
            if  let feature:Unidoc.Scalar = self.current.scalars.decls[feature]
            {
                return .scalar(feature)
            }

        case    .codelink(let expression, let location),
                .doclink(let expression, let location):
            switch self.resolve(expression, at: location)
            {
            case  nil:
                return .text(expression)

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
            .init(location: location?.map { self.current.edition + $0 })
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
