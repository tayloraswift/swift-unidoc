import SymbolGraphs

extension SymbolGraph
{
    var modules:ModuleView
    {
        .init(namespaces: self.namespaces, cultures: self.cultures)
    }
}
