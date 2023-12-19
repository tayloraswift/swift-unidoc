import SymbolGraphs
import Symbols
import UnidocAPI

extension Unidoc.Vertex
{
    @frozen public
    struct Product:Identifiable, Equatable, Sendable
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
        var group:Unidoc.Group.ID?

        @inlinable public
        init(id:Unidoc.Scalar,
            requirements:[Unidoc.Scalar],
            symbol:String,
            type:SymbolGraph.ProductType,
            group:Unidoc.Group.ID?)
        {
            self.id = id
            self.requirements = requirements
            self.symbol = symbol
            self.type = type
            self.group = group
        }
    }
}
extension Unidoc.Vertex.Product
{
    @inlinable public
    var shoot:Unidoc.Shoot { .init(stem: self.stem) }

    @inlinable public
    var stem:Unidoc.Stem { .product(Symbol.Module.init(mangling: self.symbol)) }
}
