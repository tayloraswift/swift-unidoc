import ModuleGraphs
import SymbolGraphs
import Symbols
import Unidoc

@usableFromInline internal final
class SnapshotObject:Sendable
{
    /// Maps nested declarations to scopes. Scopes might be non-local.
    private
    let hierarchy:[Int32: Unidoc.Scalar]

    let snapshot:Snapshot

    let namespaces:[Unidoc.Scalar?]
    let scalars:SymbolGraph.Plane<UnidocPlane.Decl, Unidoc.Scalar?>

    private
    init(snapshot:Snapshot,
        hierarchy:[Int32: Unidoc.Scalar],
        namespaces:[Unidoc.Scalar?],
        scalars:SymbolGraph.Plane<UnidocPlane.Decl, Unidoc.Scalar?>)
    {
        self.snapshot = snapshot
        self.hierarchy = hierarchy
        self.namespaces = namespaces
        self.scalars = scalars
    }
}
extension SnapshotObject
{
    var files:Snapshot.View<Symbol.File> { .init(self.snapshot) }
    var symbols:Snapshot.View<Symbol.Decl> { .init(self.snapshot) }
    var nodes:Snapshot.View<SymbolGraph.Node> { .init(self.snapshot) }

    var graph:SymbolGraph { self.snapshot.graph }
    var zone:Unidoc.Zone { self.snapshot.zone }
}
extension SnapshotObject
{
    convenience
    init(snapshot:__owned Snapshot, upstream:__shared DynamicContext.UpstreamScalars)
    {
        let zone:Unidoc.Zone = snapshot.zone
        let scalars:SymbolGraph.Plane<UnidocPlane.Decl, Unidoc.Scalar?> = snapshot.graph.link
        {
            zone + $0
        }
        dynamic:
        {
            upstream.citizens[$0]
        }

        let namespaces:[Unidoc.Scalar?] = snapshot.graph.namespaces.map
        {
            upstream.cultures[$0]
        }

        var hierarchy:[Int32: Unidoc.Scalar] = [:]
            hierarchy.reserveCapacity(snapshot.graph.nodes.count)

        for (n, node):(Int32, SymbolGraph.Node) in zip(
            snapshot.graph.nodes.indices,
            snapshot.graph.nodes)
        {
            for `extension`:SymbolGraph.Extension in node.extensions
            {
                for nested:Int32 in `extension`.nested where
                    snapshot.graph.citizens.contains(nested)
                {
                    hierarchy[nested] = scalars[n]
                }
            }
        }

        self.init(snapshot: snapshot,
            hierarchy: hierarchy,
            namespaces: namespaces,
            scalars: scalars)
    }
}
extension SnapshotObject
{
    func scope(of declaration:Unidoc.Scalar) -> Unidoc.Scalar?
    {
        (declaration - self.zone).map(self.scope(of:)) ?? nil
    }
    func scope(of declaration:Int32) -> Unidoc.Scalar?
    {
        self.hierarchy[declaration]
    }
}
