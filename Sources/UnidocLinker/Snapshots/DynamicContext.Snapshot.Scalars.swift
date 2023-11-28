import SymbolGraphs
import Unidoc
import UnidocRecords

extension DynamicContext.Snapshot
{
    struct Scalars
    {
        let namespaces:[Unidoc.Scalar?]
        let decls:SymbolGraph.Plane<UnidocPlane.Decl, Unidoc.Scalar?>

        private
        init(namespaces:[Unidoc.Scalar?],
            decls:SymbolGraph.Plane<UnidocPlane.Decl, Unidoc.Scalar?>)
        {
            self.namespaces = namespaces
            self.decls = decls
        }
    }
}
extension DynamicContext.Snapshot.Scalars
{
    init(snapshot:borrowing Realm.Snapshot, upstream:borrowing DynamicContext.UpstreamScalars)
    {
        let decls:SymbolGraph.Plane<UnidocPlane.Decl, Unidoc.Scalar?> =
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
