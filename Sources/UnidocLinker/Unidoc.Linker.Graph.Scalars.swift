import SymbolGraphs
import Unidoc
import UnidocRecords

extension Unidoc.Linker.Graph
{
    /// This structure provides the mappings for translating local scalars to unidoc scalars.
    /// It is optimized to perform many of these translations efficiently.
    ///
    /// Because symbol graphs can reference symbols from other packages, a single unidoc scalar
    /// might have many different local scalars that alias it. Therefore, you must only
    /// translate scalars from the same package this structure was created from.
    ///
    /// Translation of modules and declarations is fast and involves no string lookups, as the
    /// overwhemling majority of linker translations are module or declaration translations.
    /// Translation of product names is slower and involves string lookups.
    struct Scalars
    {
        let products:[String: Unidoc.Scalar]

        let modules:[Unidoc.Scalar?]
        let decls:SymbolGraph.Table<SymbolGraph.DeclPlane, Unidoc.Scalar?>

        private
        init(products:[String: Unidoc.Scalar],
            modules:[Unidoc.Scalar?],
            decls:SymbolGraph.Table<SymbolGraph.DeclPlane, Unidoc.Scalar?>)
        {
            self.products = products
            self.modules = modules
            self.decls = decls
        }
    }
}
extension Unidoc.Linker.Graph.Scalars
{
    init(_ object:borrowing SymbolGraphObject<Unidoc.Edition>,
        upstream:borrowing Unidoc.Linker.UpstreamScalars)
    {
        let decls:SymbolGraph.Table<SymbolGraph.DeclPlane, Unidoc.Scalar?> =
            object.graph.decls.link
        {
            object.id + $0
        }
        dynamic:
        {
            upstream.citizens[$0]
        }

        let modules:[Unidoc.Scalar?] = object.graph.link
        {
            object.id + $0
        }
        dynamic:
        {
            upstream.cultures[$0]
        }

        let products:[String: Unidoc.Scalar] = object.metadata.products.indices.reduce(
            into: [:])
        {
            $0[object.metadata.products[$1].name] = object.id + $1
        }

        self.init(products: products,
            modules: modules,
            decls: decls)
    }
}
