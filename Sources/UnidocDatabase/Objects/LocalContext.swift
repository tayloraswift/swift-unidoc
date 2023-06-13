import SymbolGraphs

struct LocalContext
{
    /// Maps nested declarations to scopes. Scopes might be non-local.
    private
    let hierarchy:[Int32: GlobalAddress]
    let projector:LocalProjector
    let graph:SymbolGraph

    private
    init(hierarchy:[Int32: GlobalAddress],
        projector:LocalProjector,
        graph:SymbolGraph)
    {
        self.projector = projector
        self.hierarchy = hierarchy
        self.graph = graph
    }
}
extension LocalContext
{
    init(projector:LocalProjector, graph:SymbolGraph)
    {
        var hierarchy:[Int32: GlobalAddress] = [:]
            hierarchy.reserveCapacity(graph.nodes.count)

        for (scope, node):(Int32, SymbolGraph.Node) in zip(graph.nodes.indices, graph.nodes)
        {
            for `extension`:SymbolGraph.Extension in node.extensions
            {
                for nested:Int32 in `extension`.nested
                    where graph.citizens.contains(nested)
                {
                    hierarchy[nested] = scope * projector
                }
            }
        }

        self.init(hierarchy: hierarchy, projector: projector, graph: graph)
    }
}
extension LocalContext
{
    subscript(scalar address:GlobalAddress) -> SymbolGraph.Node?
    {
        (address / self.projector).map { self.graph.nodes[$0 as Int32] }
    }

    func scope(of address:GlobalAddress) -> GlobalAddress?
    {
        (address / self.projector).map(self.scope(of:)) ?? nil
    }
    func scope(of citizen:Int32) -> GlobalAddress?
    {
        self.hierarchy[citizen]
    }

    var translator:DynamicObject.Translator
    {
        self.projector.translator
    }
}
extension LocalContext:Identifiable
{
    var id:Int32
    {
        self.projector.translator.package
    }
}

extension LocalContext
{
    func project(extension:SymbolGraph.Extension, of scope:GlobalAddress) -> ExtensionProjection
    {
        .init(conditions: `extension`.conditions.map
            {
                $0.map { $0 * self.projector }
            },
            culture: self.translator[culture: `extension`.culture],
            scope: scope,
            conformances: `extension`.conformances.compactMap
            {
                $0 * self.projector
            },
            features: `extension`.features.compactMap
            {
                $0 * self.projector
            },
            nested: `extension`.nested.compactMap
            {
                $0 * self.projector
            })
    }
}
