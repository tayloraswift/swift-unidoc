import ModuleGraphs
import SymbolGraphs

final
class SnapshotObject:Sendable
{
    /// Maps nested declarations to scopes. Scopes might be non-local.
    private
    let hierarchy:[Int32: GlobalAddress]
    let projector:Projector

    private
    init(hierarchy:[Int32: GlobalAddress],
        projector:Projector)
    {
        self.hierarchy = hierarchy
        self.projector = projector
    }
}
extension SnapshotObject
{
    var snapshot:Snapshot { self.projector.snapshot }
    var graph:SymbolGraph { self.projector.graph }

    var translator:Snapshot.Translator { self.snapshot.translator }
}
extension SnapshotObject
{
    private convenience
    init(projector:__owned Projector)
    {
        var hierarchy:[Int32: GlobalAddress] = [:]
            hierarchy.reserveCapacity(projector.graph.nodes.count)

        for (scope, node):(Int32, SymbolGraph.Node) in zip(
            projector.graph.nodes.indices,
            projector.graph.nodes)
        {
            for `extension`:SymbolGraph.Extension in node.extensions
            {
                for nested:Int32 in `extension`.nested
                    where projector.graph.citizens.contains(nested)
                {
                    hierarchy[nested] = scope * projector
                }
            }
        }

        self.init(hierarchy: hierarchy, projector: projector)
    }

    convenience
    init(snapshot:__owned Snapshot, upstream:__shared UpstreamSymbols)
    {
        self.init(projector: .init(snapshot: snapshot, upstream: upstream))
    }
}
extension SnapshotObject
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
}
extension SnapshotObject
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
