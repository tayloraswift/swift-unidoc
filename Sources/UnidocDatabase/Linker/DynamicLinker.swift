import CodelinkResolution
import SymbolGraphs
import Symbols

struct DynamicLinker
{
    private
    let context:GlobalContext
    private
    let resolver:CodelinkResolver<GlobalAddress>

    private
    var extensions:Extensions
    private
    let conformances:SymbolGraph.Table<Conformances>

    private
    init(context:GlobalContext,
        resolver:CodelinkResolver<GlobalAddress>,
        extensions:Extensions,
        conformances:SymbolGraph.Table<Conformances>)
    {
        self.context = context
        self.resolver = resolver

        self.extensions = extensions
        self.conformances = conformances
    }
}
extension DynamicLinker
{
    private
    init(context:GlobalContext,
        extensions:Extensions,
        conformances:SymbolGraph.Table<Conformances>)
    {
        var resolver:CodelinkResolver<GlobalAddress> = .init()
        for dependency:LocalContext in context.upstream.values
        {
            resolver.expose(upstream: dependency, in: context)
        }
        self.init(context: context,
            resolver: resolver,
            extensions: extensions,
            conformances: conformances)
    }
    init(context:GlobalContext)
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

        self.init(context: context, extensions: extensions, conformances: conformances)
    }
}
extension DynamicLinker
{
    var current:LocalContext { self.context.current }
}
extension DynamicLinker
{
    mutating
    func project() -> [ScalarProjection]
    {
        var scalars:[ScalarProjection] = []

        for (index, culture):(Int, SymbolGraph.Culture) in
            self.current.graph.cultures.enumerated()
        {
            let culture:(address:GlobalAddress, value:SymbolGraph.Culture) =
            (
                self.current.translator[culture: index],
                culture
            )
            for namespace:SymbolGraph.Namespace in culture.value.namespaces
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

                    for feature:Int32 in scalar.features
                    {
                        if  let `protocol`:GlobalAddress = self.current.scope(of: feature),
                            let feature:GlobalAddress = feature * self.current.projector
                        {
                            //  now that we know the address of the feature’s original protocol,
                            //  we can look up the constraints for the conformance(s) that
                            //  conceived it.
                            for conformance:GlobalSignature in conformances[to: `protocol`]
                            {
                                self.extensions[conformance].features.append(feature)
                            }
                        }
                    }
                    for superform:Int32 in scalar.superforms
                    {
                        if  let superform:GlobalAddress = superform * self.current.projector
                        {
                            let implicit:GlobalSignature = .init(conditions: [],
                                culture: culture.address,
                                scope: superform)

                            self.extensions[implicit].subforms.append(citizen)
                        }
                    }

                    scalars.append(.init(id: citizen,
                        culture: culture.address,
                        scope: scope.map(self.context.expand),
                        declaration: scalar.declaration.map { $0 * self.current.projector }))
                }
            }
        }

        return scalars
    }
}
