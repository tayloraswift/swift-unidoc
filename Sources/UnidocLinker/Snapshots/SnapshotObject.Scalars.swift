import ModuleGraphs
import SymbolGraphs
import Unidoc

extension SnapshotObject
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
extension SnapshotObject.Scalars
{
    init(snapshot:__shared Snapshot, upstream:__shared DynamicContext.UpstreamScalars)
    {
        let decls:SymbolGraph.Plane<UnidocPlane.Decl, Unidoc.Scalar?> =
            snapshot.graph.decls.link
        {
            snapshot.zone + $0
        }
        dynamic:
        {
            upstream.citizens[$0]
        }

        let namespaces:[Unidoc.Scalar?] = snapshot.graph.link
        {
            snapshot.zone + $0
        }
        dynamic:
        {
            upstream.cultures[$0]
        }

        self.init(namespaces: namespaces, decls: decls)
    }
}
