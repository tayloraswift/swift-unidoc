import CodelinkResolution
import Codelinks
import Doclinks
import ModuleGraphs
import SymbolGraphs
import UnidocDiagnostics

enum _CodelinkExpansion
{
    case text(String)
    case path([Scalar96])
}

struct DynamicResolver
{
    private(set)
    var diagnoses:[any DynamicDiagnosis]

    private
    let codelinks:CodelinkResolver<Scalar96>
    private
    let context:DynamicContext

    private
    init(codelinks:CodelinkResolver<Scalar96>, context:DynamicContext)
    {
        self.diagnoses = []

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
    func link(article:SymbolGraph.Article<some Any>)
    {
        let _:[_CodelinkExpansion] = article.referents.map
        {
            switch $0
            {
            case .scalar(let referent):
                if      let _:Int = referent.scalar & .declaration,
                        let scalar:Scalar96 = self.current.declarations[referent.scalar]
                {
                    return .path(self.context.expand(scalar, to: referent.length))
                }
                else if let _:Int = referent.scalar & .article
                {
                    return .path([self.current.translator[citizen: referent.scalar]])
                }
                else if let _:Int = referent.scalar & .file
                {
                    //  TODO: implement me
                }
                else if let namespace:Int = referent.scalar & .module,
                        let scalar:Scalar96 = self.current.namespaces[namespace]
                {
                    return .path([scalar])
                }

            case .vector(let referent):
                //  Only references to declarations can generate vectors. So we can assume
                //  both components are declaration scalars.
                if  let feature:Scalar96 = self.current.declarations[referent.feature],
                    let heir:Scalar96 = self.current.declarations[referent.heir]
                {
                    return .path(self.context.expand((heir, feature), to: referent.length))
                }

            case .unresolved(let referent):
                return self.expand(referent)
            }

            return .text("<unavailable>")
        }
    }

    private mutating
    func expand(_ referent:SymbolGraph.Referent.Unresolved) -> _CodelinkExpansion
    {
        var context:Diagnostic.Context<Scalar96>
        {
            .init(location: referent.location?.map { self.current.translator[citizen: $0] })
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
            self.diagnoses.append(InvalidAutolinkError<Scalar96>.init(
                expression: referent.expression,
                context: context))
            return .text(referent.expression)
        }

        switch self.codelinks.resolve(codelink)
        {
        case .some(let overloads):
            self.diagnoses.append(InvalidCodelinkError<Scalar96>.init(
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
