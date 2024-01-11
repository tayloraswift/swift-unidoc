import FNV1
import SymbolGraphs
import Symbols
import UnidocAPI

extension Unidoc
{
    @frozen public
    struct ProductVertex:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Scalar
        public
        let requirements:[Unidoc.Scalar]
        public
        let symbol:String
        public
        let type:SymbolGraph.ProductType

        public
        var group:Unidoc.Group?

        @inlinable public
        init(id:Unidoc.Scalar,
            requirements:[Unidoc.Scalar],
            symbol:String,
            type:SymbolGraph.ProductType,
            group:Unidoc.Group?)
        {
            self.id = id
            self.requirements = requirements
            self.symbol = symbol
            self.type = type
            self.group = group
        }
    }
}
extension Unidoc.ProductVertex:Unidoc.PrincipalVertex
{
    @inlinable public
    var stem:Unidoc.Stem { .product(Symbol.Module.init(mangling: self.symbol)) }

    @inlinable public
    var hash:FNV24.Extended { .init(hashing: "s:p:\(self.symbol)") }
}
