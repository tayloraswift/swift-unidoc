import ModuleGraphs
import SymbolGraphs

extension SymbolGraph
{
    struct ModuleView
    {
        let namespaces:[ModuleIdentifier]
        let cultures:[Culture]

        init(namespaces:[ModuleIdentifier], cultures:[Culture])
        {
            self.namespaces = namespaces
            self.cultures = cultures
        }
    }
}
extension SymbolGraph.ModuleView:RandomAccessCollection
{
    var startIndex:Int { self.cultures.startIndex }
    var endIndex:Int { self.cultures.endIndex }

    subscript(culture:Int) -> (index:Int, name:ModuleIdentifier, culture:SymbolGraph.Culture)
    {
        (culture, self.namespaces[culture], self.cultures[culture])
    }
}
