import CodelinkResolution
import Codelinks
import Doclinks
import ModuleGraphs
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
        group:DynamicResolutionGroup,
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
        let referents:[Record.Passage.Referent] = article.referents.map { self.link($0) }

        let overview:Record.Passage? = article.overview.isEmpty ? nil : .init(
            referents: .init(referents.prefix(article.fold)),
            markdown: article.overview)
        let details:Record.Passage? = article.details.isEmpty ? nil : .init(
            referents: .init(referents.dropFirst(article.fold)),
            markdown: article.details)
        return (overview, details)
    }

    private mutating
    func link(_ referent:SymbolGraph.Referent) -> Record.Passage.Referent
    {
        switch referent
        {
        case .scalar(let referent):
            if      let _:Int = referent.scalar / .decl,
                    let scalar:Unidoc.Scalar = self.current.decls[referent.scalar]
            {
                return .path(self.context.expand(scalar, to: referent.length))
            }
            else if let _:Int = referent.scalar / .article
            {
                return .path([self.current.zone + referent.scalar])
            }
            else if let _:Int = referent.scalar / .file
            {
                //  TODO: implement me
            }
            else if let namespace:Int = referent.scalar / .module,
                    let scalar:Unidoc.Scalar = self.current.namespaces[namespace]
            {
                return .path([scalar])
            }

        case .vector(let referent):
            //  Only references to declarations can generate vectors. So we can assume
            //  both components are declaration scalars.
            if  let feature:Unidoc.Scalar = self.current.decls[referent.feature],
                let heir:Unidoc.Scalar = self.current.decls[referent.heir]
            {
                return .path(self.context.expand((heir, feature), to: referent.length))
            }

        case .unresolved(let referent):
            return self.expand(referent)
        }

        return .text("<unavailable>")
    }

    private mutating
    func expand(_ referent:SymbolGraph.Referent.Unresolved) -> Record.Passage.Referent
    {
        var context:Diagnostic.Context<Unidoc.Scalar>
        {
            .init(location: referent.location?.map { self.current.zone + $0 })
        }

        let codelink:Codelink?

        if  let doclink:Doclink = .init(referent.expression)
        {
            codelink = .init(doclink.path.joined(separator: "/"))
        }
        else
        {
            codelink = .init(referent.expression)
        }
        guard let codelink:Codelink
        else
        {
            //  Somehow, a symbolgraph was compiled with an unparseable codelink!
            self.errors.append(InvalidAutolinkError<Unidoc.Scalar>.init(
                expression: referent.expression,
                context: context))
            return .text(referent.expression)
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
            let length:UInt32 = .init(codelink.path.components.count)
            switch overload.target
            {
            case .scalar(let scalar):
                return .path(self.context.expand(scalar, to: length))

            case .vector(let feature, self: let heir):
                return .path(self.context.expand((heir, feature), to: length))
            }
        }
    }
}
