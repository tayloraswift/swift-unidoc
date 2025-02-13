import SymbolGraphs
import Symbols

extension PackageNode
{
    @frozen public
    struct Densified
    {
        public
        let dependencies:[any Identifiable<Symbol.Package>]
        public
        let products:[SymbolGraph.Product]
        public
        let modules:[SymbolGraph.Module]

        init(dependencies:[any Identifiable<Symbol.Package>],
            products:[SymbolGraph.Product],
            modules:[SymbolGraph.Module])
        {
            self.dependencies = dependencies
            self.products = products
            self.modules = modules
        }
    }
}
