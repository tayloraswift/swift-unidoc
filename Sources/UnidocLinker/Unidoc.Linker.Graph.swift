import SymbolGraphs
import Symbols
import Unidoc
import UnidocRecords

extension Unidoc.Linker
{
    @available(*, deprecated, renamed: "Unidoc.Linker.Graph")
    @usableFromInline
    typealias Snapshot = Graph
}
extension Unidoc.Linker
{
    @dynamicMemberLookup
    @usableFromInline final
    class Graph
    {
        let id:Unidoc.Edition
        /// Maps declarations to module namespaces. For declarations nested inside types from
        /// upstream modules, this is the index of the module of the outermost type. If this is
        /// the case, then the index is only valid within this snapshot.
        private
        let qualifiers:[Int32: Int]
        /// Maps nested declarations to scopes. Scopes might be non-local.
        private
        let hierarchy:[Int32: Unidoc.Scalar]

        let scalars:Scalars

        let metadata:SymbolGraphMetadata
        let graph:SymbolGraph

        private
        init(id:Unidoc.Edition,
            qualifiers:[Int32: Int],
            hierarchy:[Int32: Unidoc.Scalar],
            scalars:Scalars,
            metadata:SymbolGraphMetadata,
            graph:SymbolGraph)
        {
            self.id = id

            self.qualifiers = qualifiers
            self.hierarchy = hierarchy
            self.scalars = scalars

            self.metadata = metadata
            self.graph = graph
        }
    }
}
extension Unidoc.Linker.Graph
{
    subscript<T>(dynamicMember keyPath:KeyPath<SymbolGraph, T>) -> T
    {
        self.graph[keyPath: keyPath]
    }
}
extension Unidoc.Linker.Graph
{
    convenience
    init(snapshot:Unidoc.Snapshot, upstream:borrowing Unidoc.Linker.UpstreamScalars)
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

            if  let decl:SymbolGraph.Decl = node.decl
            {
                for requirement:Int32 in decl.requirements
                {
                    hierarchy[requirement] = n
                }
                for inhabitant:Int32 in decl.inhabitants
                {
                    hierarchy[inhabitant] = n
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

        self.init(id: snapshot.id,
            qualifiers: qualifiers,
            hierarchy: hierarchy,
            scalars: scalars,
            metadata: snapshot.metadata,
            graph: snapshot.graph)
    }
}
extension Unidoc.Linker.Graph
{
    func namespace(of declaration:Unidoc.Scalar) -> Symbol.Module?
    {
        (declaration - self.id).map(self.namespace(of:)) ?? nil
    }
    /// Returns the module namespace of the requested declaration, if the requested declaration
    /// is a citizen of this snapshot.
    ///
    /// This returns nil if the requested declaration is a top-level declaration, of if it
    /// is not a citizen of this snapshot.
    func namespace(of declaration:Int32) -> Symbol.Module?
    {
        self.qualifiers[declaration].map { self.namespaces[$0] }
    }

    func scope(of declaration:Unidoc.Scalar) -> Unidoc.Scalar?
    {
        (declaration - self.id).map(self.scope(of:)) ?? nil
    }
    /// Returns the lexical scope of the requested declaration, if the requested declaration
    /// is a citizen of this snapshot.
    ///
    /// This returns nil if the requested declaration is a top-level declaration, or if it
    /// is not a citizen of this snapshot.
    func scope(of declaration:Int32) -> Unidoc.Scalar?
    {
        self.hierarchy[declaration]
    }
}
