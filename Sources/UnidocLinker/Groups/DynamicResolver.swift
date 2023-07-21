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
    let codelinks:CodelinkResolver<Unidoc.Scalar>
    private
    let context:DynamicContext

    private(set)
    var errors:[any DynamicLinkerError]

    private
    init(codelinks:CodelinkResolver<Unidoc.Scalar>, context:DynamicContext)
    {
        self.errors = []

        self.codelinks = codelinks
        self.context = context
    }
}
extension DynamicResolver
{
    init(context:DynamicContext,
        namespace:ModuleIdentifier,
        group:DynamicClientGroup,
        scope:[String] = [])
    {
        self.init(codelinks: .init(table: group.codelinks, scope: .init(
                namespace: namespace,
                imports: group.imports,
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
    mutating
    func link(article:SymbolGraph.Article<some Any>) ->
    (
        overview:Record.Passage?,
        details:Record.Passage?
    )
    {
        let outlines:[Record.Outline] = article.outlines.map { self.link($0) }

        let overview:Record.Passage? = article.overview.isEmpty ? nil : .init(
            outlines: .init(outlines.prefix(article.fold)),
            markdown: article.overview)
        let details:Record.Passage? = article.details.isEmpty ? nil : .init(
            outlines: .init(outlines.dropFirst(article.fold)),
            markdown: article.details)
        return (overview, details)
    }

    private mutating
    func link(_ outline:SymbolGraph.Outline) -> Record.Outline
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
                    let scalar:Unidoc.Scalar = self.current.scalars[scalar]
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
                    let scalar:Unidoc.Scalar = self.current.namespaces[namespace]
            {
                return .path(outline.text, [scalar])
            }

        case .vector(let feature, self: let heir):
            //  Only references to declarations can generate vectors. So we can assume
            //  both components are declaration scalars.
            if  let feature:Unidoc.Scalar = self.current.scalars[feature],
                let heir:Unidoc.Scalar = self.current.scalars[heir]
            {
                return .path(outline.text, self.context.expand((heir, feature), to: length))
            }

        case .unresolved(let location):
            return self.expand(afterResolving: outline.text, at: location)
        }

        return .text("<unavailable>")
    }

    private mutating
    func expand(
        afterResolving expression:String,
        at location:SourceLocation<Int32>?) -> Record.Outline
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
            self.errors.append(InvalidAutolinkError<Unidoc.Scalar>.init(
                expression: expression,
                context: context))
            return .text(expression)
        }

        switch self.codelinks.resolve(codelink)
        {
        case .some(let overloads):
            self.errors.append(InvalidCodelinkError<Unidoc.Scalar>.init(
                overloads: overloads,
                codelink: codelink,
                context: context))
            return .text("\(codelink.path)")

        case .one(let overload):
            let length:Int = codelink.path.components.count
            switch overload.target
            {
            case .scalar(let scalar):
                return .path(expression, self.context.expand(scalar, to: length))

            case .vector(let feature, self: let heir):
                return .path(expression, self.context.expand((heir, feature), to: length))
            }
        }
    }
}
