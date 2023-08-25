import ModuleGraphs
import SymbolGraphs
import Symbols
import Unidoc

@dynamicMemberLookup
@usableFromInline internal final
class SnapshotObject:Sendable
{
    /// Maps nested declarations to scopes. Scopes might be non-local.
    private
    let hierarchy:[Int32: Unidoc.Scalar]

    let snapshot:Snapshot
    let scalars:Scalars

    private
    init(snapshot:Snapshot,
        hierarchy:[Int32: Unidoc.Scalar],
        scalars:Scalars)
    {
        self.snapshot = snapshot
        self.hierarchy = hierarchy
        self.scalars = scalars
    }
}
extension SnapshotObject
{
    var metadata:SymbolGraphMetadata { self.snapshot.metadata }
    var zone:Unidoc.Zone { self.snapshot.zone }
}
extension SnapshotObject
{
    subscript<T>(dynamicMember keyPath:KeyPath<SymbolGraph, T>) -> T
    {
        self.snapshot.graph[keyPath: keyPath]
    }
}
extension SnapshotObject
{
    convenience
    init(snapshot:__owned Snapshot, upstream:__shared DynamicContext.UpstreamScalars)
    {
        let scalars:Scalars = .init(snapshot: snapshot, upstream: upstream)

        var hierarchy:[Int32: Unidoc.Scalar] = [:]
            hierarchy.reserveCapacity(snapshot.graph.decls.nodes.count)

        for (n, node):(Int32, SymbolGraph.DeclNode) in zip(
            snapshot.graph.decls.nodes.indices,
            snapshot.graph.decls.nodes)
        {
            guard let n:Unidoc.Scalar = scalars.decls[n]
            else
            {
                continue
            }

            if  let requirements:[Int32] = node.decl?.requirements
            {
                for requirement:Int32 in requirements
                {
                    hierarchy[requirement] = n
                }
            }
            for `extension`:SymbolGraph.Extension in node.extensions
            {
                for nested:Int32 in `extension`.nested where
                    snapshot.graph.decls.contains(citizen: nested)
                {
                    hierarchy[nested] = n
                }
            }
        }

        self.init(snapshot: snapshot,
            hierarchy: hierarchy,
            scalars: scalars)
    }
}
extension SnapshotObject
{
    func priority(of decl:Unidoc.Scalar) -> (DynamicContext.SortLeague, String, Int32)?
    {
        if  let local:Int32 = decl - self.zone,
            let decl:SymbolGraph.Decl = snapshot.graph.decls[local]?.decl
        {
            let league:DynamicContext.SortLeague = .init(decl.phylum,
                position: decl.location?.position)
            return (league, decl.path.last, local)
        }
        else
        {
            return nil
        }
    }

    func scope(of declaration:Unidoc.Scalar) -> Unidoc.Scalar?
    {
        (declaration - self.zone).map(self.scope(of:)) ?? nil
    }
    /// Returns the lexical scope of the requested declaration, if the requested declaration
    /// is a citizen of this snapshot.
    func scope(of declaration:Int32) -> Unidoc.Scalar?
    {
        self.hierarchy[declaration]
    }
}
