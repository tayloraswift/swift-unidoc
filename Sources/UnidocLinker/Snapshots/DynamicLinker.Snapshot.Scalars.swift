import SymbolGraphs
import Unidoc
import UnidocRecords

extension DynamicLinker.Snapshot
{
    struct Scalars
    {
        let namespaces:[Unidoc.Scalar?]
        let decls:SymbolGraph.Table<SymbolGraph.Plane.Decl, Unidoc.Scalar?>

        private
        init(namespaces:[Unidoc.Scalar?],
            decls:SymbolGraph.Table<SymbolGraph.Plane.Decl, Unidoc.Scalar?>)
        {
            self.namespaces = namespaces
            self.decls = decls
        }
    }
}
extension DynamicLinker.Snapshot.Scalars
{
    init(snapshot:borrowing Unidoc.Snapshot, upstream:borrowing DynamicLinker.UpstreamScalars)
    {
        let decls:SymbolGraph.Table<SymbolGraph.Plane.Decl, Unidoc.Scalar?> =
            snapshot.graph.decls.link
        {
            snapshot.id + $0
        }
        dynamic:
        {
            upstream.citizens[$0]
        }

        let namespaces:[Unidoc.Scalar?] = snapshot.graph.link
        {
            snapshot.id + $0
        }
        dynamic:
        {
            upstream.cultures[$0]
        }

        self.init(namespaces: namespaces, decls: decls)
    }
}
