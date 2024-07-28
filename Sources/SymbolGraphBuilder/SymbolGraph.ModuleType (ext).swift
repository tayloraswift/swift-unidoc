import SymbolGraphs

extension SymbolGraph.ModuleType
{
    var hasSymbols:Bool
    {
        switch self
        {
        case .binary:       true
        case .executable:   false
        case .regular:      true
        case .macro:        true
        case .plugin:       false
        case .snippet:      false
        case .system:       false
        case .test:         false
        case .book:         false
        }
    }
}
