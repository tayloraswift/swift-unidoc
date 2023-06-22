import CodelinkResolution
import ModuleGraphs
import SymbolGraphs
import Symbols

struct DynamicLinker
{
    private
    let conformances:SymbolGraph.Table<Conformances>
    private
    let context:DynamicContext

    private
    var extensions:Extensions

    private
    init(conformances:SymbolGraph.Table<Conformances>,
        context:DynamicContext,
        extensions:Extensions)
    {
        self.conformances = conformances
        self.context = context

        self.extensions = extensions
    }
}
extension DynamicLinker
{
    init(context:DynamicContext)
    {
        var extensions:Extensions = [:]
        let conformances:SymbolGraph.Table<Conformances> = context.current.graph.nodes.map
        {
            if  $1.extensions.isEmpty
            {
                return [:]
            }
            guard let scope:GlobalAddress = $0 * context.current.projector
            else
            {
                return [:]
            }

            var conformances:DynamicLinker.Conformances = [:]
            for `extension`:SymbolGraph.Extension in $1.extensions
            {
                let projected:ExtensionProjection = context.current.project(
                    extension: `extension`,
                    of: scope)

                //  we only need the conformances if the scalar has unqualified features
                if case false? = $1.scalar?.features.isEmpty
                {
                    for `protocol`:GlobalAddress in projected.conformances
                    {
                        conformances[to: `protocol`].append(projected.signature)
                    }
                }

                //  It’s possible for two locally-disjoint extensions to coalesce
                //  into a single global extension due to constraint dropping...
                extensions[projected.signature].merge(with: projected)
            }

            return conformances
        }

        self.init(conformances: conformances, context: context, extensions: extensions)
    }
}
extension DynamicLinker
{
    var current:SnapshotObject { self.context.current }
}
extension DynamicLinker
{
    mutating
    func project() -> [ScalarProjection]
    {
        var scalars:[ScalarProjection] = []

        let groups:[DynamicResolutionGroup] = self.context.groups()
        for (c, culture):(Int, SymbolGraph.Culture) in zip(
            self.current.graph.cultures.indices,
            self.current.graph.cultures)
        {
            let group:DynamicResolutionGroup = groups[c]
            let c:GlobalAddress = self.current.translator[culture: c]

            for namespace:SymbolGraph.Namespace in culture.namespaces
            {
                for citizen:Int32 in namespace.range
                {
                    let conformances:Conformances = self.conformances[citizen]
                    let scope:GlobalAddress? = self.current.scope(of: citizen)
                    let node:SymbolGraph.Node = self.current.graph.nodes[citizen]

                    //  Ceremonial unwraps, should always succeed since we are only iterating
                    //  over module ranges.
                    guard   let citizen:GlobalAddress = citizen * self.current.projector,
                            let scalar:SymbolGraph.Scalar = node.scalar
                    else
                    {
                        continue
                    }

                    for f:Int32 in scalar.features
                    {
                        if  let `protocol`:GlobalAddress = self.current.scope(of: f),
                            let f:GlobalAddress = f * self.current.projector
                        {
                            //  now that we know the address of the feature’s original
                            //  protocol, we can look up the constraints for the
                            //  conformance(s) that conceived it.
                            for conformance:GlobalSignature in conformances[to: `protocol`]
                            {
                                self.extensions[conformance].features.append(f)
                            }
                        }
                    }
                    for s:Int32 in scalar.superforms
                    {
                        if  let s:GlobalAddress = s * self.current.projector
                        {
                            let implicit:GlobalSignature = .init(conditions: [],
                                culture: c,
                                scope: s)

                            self.extensions[implicit].subforms.append(citizen)
                        }
                    }

                    if  let article:SymbolGraph.Article<Never> = scalar.article
                    {
                        group.link(article: article,
                            namespace: self.current.graph.namespaces[namespace.index],
                            scope: scalar.phylum.scope(trimming: scalar.path))
                    }

                    scalars.append(.init(id: citizen,
                        culture: c,
                        scope: scope.map(self.context.expand),
                        declaration: scalar.declaration.map { $0 * self.current.projector }))
                }
            }
        }

        return scalars
    }
}
