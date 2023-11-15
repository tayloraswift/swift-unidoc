import ModuleGraphs
import SymbolGraphs
import Unidoc

extension SymbolGraph
{
    struct ModuleView
    {
        let namespaces:[ModuleIdentifier]
        let cultures:[Culture]
        let contexts:[ModuleContext]
        let edition:Unidoc.Edition

        init(namespaces:[ModuleIdentifier],
            cultures:[Culture],
            contexts:[ModuleContext],
            edition:Unidoc.Edition)
        {
            self.namespaces = namespaces
            self.cultures = cultures
            self.contexts = contexts
            self.edition = edition
        }
    }
}
extension SymbolGraph.ModuleView:RandomAccessCollection
{
    var startIndex:Int { self.cultures.startIndex }
    var endIndex:Int { self.cultures.endIndex }

    subscript(culture:Int) ->
    (
        namespace:SymbolGraph.NamespaceContext<Void>,
        culture:SymbolGraph.Culture
    )
    {
        let namespace:SymbolGraph.NamespaceContext<Void> = .init(
            context: self.contexts[culture],
            culture: self.edition + culture,
            module: self.namespaces[culture])

        return (namespace, self.cultures[culture])
    }
}
