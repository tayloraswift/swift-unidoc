import ModuleGraphs
import SymbolGraphs
import Symbols
import Unidoc

@dynamicMemberLookup
@usableFromInline internal final
class SnapshotObject:Sendable
{
    /// Maps declarations to module namespaces. For declarations nested inside types from
    /// upstream modules, this is the index of the module of the outermost type. If this is
    /// the case, then the index is only valid within this snapshot.
    private
    let qualifiers:[Int32: Int]
    /// Maps nested declarations to scopes. Scopes might be non-local.
    private
    let hierarchy:[Int32: Unidoc.Scalar]

    let snapshot:Snapshot
    let scalars:Scalars

    private
    init(snapshot:Snapshot,
        qualifiers:[Int32: Int],
        hierarchy:[Int32: Unidoc.Scalar],
        scalars:Scalars)
    {
        self.snapshot = snapshot
        self.qualifiers = qualifiers
        self.hierarchy = hierarchy
        self.scalars = scalars
    }
}
extension SnapshotObject
{
    var metadata:SymbolGraphMetadata { self.snapshot.metadata }
    var edition:Unidoc.Zone { self.snapshot.edition }
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

        var qualifiers:[Int32: Int] = [:]

        for culture:SymbolGraph.Culture in snapshot.graph.cultures
        {
            for namespace:SymbolGraph.Namespace in culture.namespaces
            {
                for d:Int32 in namespace.range
                {
                    qualifiers[d] = namespace.index
                }
            }
        }

        self.init(snapshot: snapshot,
            qualifiers: qualifiers,
            hierarchy: hierarchy,
            scalars: scalars)
    }
}
extension SnapshotObject
{
    func priority(of decl:Unidoc.Scalar) -> DynamicContext.SortPriority?
    {
        if  let local:Int32 = decl - self.edition,
            let decl:SymbolGraph.Decl = self.decls[local]?.decl
        {
            let phylum:DynamicContext.SortPriority.Phylum = .init(decl.phylum,
                position: decl.location?.position)
            return decl.signature.availability.isGenerallyRecommended ?
                .available(phylum, decl.path.last, local) :
                .removed(phylum, decl.path.last, local)
        }
        else
        {
            return nil
        }
    }

    func namespace(of declaration:Unidoc.Scalar) -> ModuleIdentifier?
    {
        (declaration - self.edition).map(self.namespace(of:)) ?? nil
    }
    /// Returns the module namespace of the requested declaration, if the requested declaration
    /// is a citizen of this snapshot.
    ///
    /// This returns nil if the requested declaration is a top-level declaration, of if it
    /// is not a citizen of this snapshot.
    func namespace(of declaration:Int32) -> ModuleIdentifier?
    {
        self.qualifiers[declaration].map { self.namespaces[$0] }
    }

    func scope(of declaration:Unidoc.Scalar) -> Unidoc.Scalar?
    {
        (declaration - self.edition).map(self.scope(of:)) ?? nil
    }
    /// Returns the lexical scope of the requested declaration, if the requested declaration
    /// is a citizen of this snapshot.
    ///
    /// This returns nil if the requested declaration is a top-level declaration, of if it
    /// is not a citizen of this snapshot.
    func scope(of declaration:Int32) -> Unidoc.Scalar?
    {
        self.hierarchy[declaration]
    }
}
