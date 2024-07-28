import SymbolGraphs
import System

extension SSGC.ModuleLayout
{
    enum DefaultDirectory:Equatable, Hashable
    {
        case plugins
        case snippets
        case sources
        case tests
    }
}
extension SSGC.ModuleLayout.DefaultDirectory
{
    init?(for type:SymbolGraph.ModuleType)
    {
        switch type
        {
        case .binary:       return nil
        case .executable:   self = .sources
        case .regular:      self = .sources
        case .macro:        self = .sources
        case .plugin:       self = .plugins
        case .snippet:      self = .snippets
        case .system:       self = .sources
        case .test:         self = .tests
        case .book:         return nil
        }
    }
}
extension SSGC.ModuleLayout.DefaultDirectory
{
    var name:FilePath.Component
    {
        switch self
        {
        case .plugins:  "Plugins"
        case .snippets: "Snippets"
        case .sources:  "Sources"
        case .tests:    "Tests"
        }
    }
}
