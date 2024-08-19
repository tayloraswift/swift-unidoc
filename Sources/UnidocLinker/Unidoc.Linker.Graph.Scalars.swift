import MD5
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

        let hash:MD5

        private
        init(products:[String: Unidoc.Scalar],
            modules:[Unidoc.Scalar?],
            decls:SymbolGraph.Table<SymbolGraph.DeclPlane, Unidoc.Scalar?>,
            hash:MD5)
        {
            self.products = products
            self.modules = modules
            self.decls = decls
            self.hash = hash
        }
    }
}
extension Unidoc.Linker.Graph.Scalars
{
    init(_ object:borrowing SymbolGraphObject<Unidoc.Edition>,
        upstream:borrowing Unidoc.Linker.UpstreamScalars)
    {
        var signature:[UInt8] = []
        var salt:Int32 = 0
        /// Multiplying the indices by a prime number helps prevent hash degeneracy from
        /// contiguous ascending indices.
        let p:Int32 = 2_147_483_647

        let modules:[Unidoc.Scalar?] = object.graph.link
        {
            signature += $0.mangled.utf8
            signature.append(0)
            salt ^= p &* $1
            return object.id + $1
        }
        dynamic:
        {
            upstream.cultures[$0]
        }

        /// We don’t currently support cross-package references for articles, but we include
        /// them in the signature so that we don’t need to change the hash function if we add
        /// such a feature in the future.
        let _:SymbolGraph.Table<SymbolGraph.ArticlePlane, Unidoc.Scalar?> =
            object.graph.articles.link
        {
            signature += $0.rawValue.utf8
            signature.append(0)
            salt ^= p &* $1
            return object.id + $1
        }
        dynamic:
        {
            _ in nil
        }

        let decls:SymbolGraph.Table<SymbolGraph.DeclPlane, Unidoc.Scalar?> =
            object.graph.decls.link
        {
            signature += $0.rawValue.utf8
            signature.append(0)
            salt ^= p &* $1
            return object.id + $1
        }
        dynamic:
        {
            upstream.citizens[$0]
        }

        let products:[String: Unidoc.Scalar] = object.metadata.products.indices.reduce(
            into: [:])
        {
            let name:String = object.metadata.products[$1].name
            signature += name.utf8
            signature.append(0)
            $0[name] = object.id + $1
        }

        withUnsafeBytes(of: salt.bigEndian)
        {
            signature += $0
        }

        self.init(products: products,
            modules: modules,
            decls: decls,
            hash: .init(hashing: signature))
    }
}
