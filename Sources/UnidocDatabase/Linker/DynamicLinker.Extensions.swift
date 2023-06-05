import SymbolGraphs

extension DynamicLinker
{
    struct Extensions
    {
        private
        var projections:[GlobalSignature: ExtensionProjection]

        init()
        {
            self.projections = [:]
        }
    }
}
extension DynamicLinker.Extensions
{
    subscript(signature:GlobalSignature) -> ExtensionProjection
    {
        _read
        {
            yield  self.projections[signature, default: .init(signature: signature)]
        }
        _modify
        {
            yield &self.projections[signature, default: .init(signature: signature)]
        }
    }
}
extension DynamicLinker.Extensions
{
    mutating
    func conformances(in current:LocalContext) -> [DynamicLinker.Conformances]
    {
        current.docs.graph.allocated.map
        {
            let node:SymbolGraph.Node = current.docs.graph[allocated: $0]
            if  node.extensions.isEmpty
            {
                return [:]
            }
            guard let scope:GlobalAddress = $0 * current.projector
            else
            {
                return [:]
            }

            var conformances:DynamicLinker.Conformances = [:]
            for `extension`:SymbolGraph.Extension in node.extensions
            {
                let projected:ExtensionProjection = current.project(
                    extension: `extension`,
                    of: scope)

                //  we only need the conformances if the scalar has unqualified features
                if case false? = node.scalar?.features.isEmpty
                {
                    for `protocol`:GlobalAddress in projected.conformances
                    {
                        conformances[to: `protocol`].append(projected.signature)
                    }
                }

                //  It’s possible for two locally-disjoint extensions to coalesce
                //  into a single global extension due to constraint dropping...
                self[projected.signature].merge(with: projected)
            }

            return conformances
        }
    }
}
