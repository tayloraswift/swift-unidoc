import SymbolGraphs
import System

extension SSGC.NominalSources
{
    enum DefaultDirectory:Equatable, Hashable
    {
        case plugins
        case snippets
        case sources
        case tests
    }
}
extension SSGC.NominalSources.DefaultDirectory
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
        }
    }
}
extension SSGC.NominalSources.DefaultDirectory
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
