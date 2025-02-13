import MarkdownABI
import SymbolGraphs
import Symbols
import SystemIO

extension SSGC
{
    /// Stores information about the source files for a package.
    struct StandardLibrarySources
    {
        let modules:ModuleGraph
        let symbols:[FilePath.Directory]

        init(modules:ModuleGraph, symbols:[FilePath.Directory])
        {
            self.modules = modules
            self.symbols = symbols
        }
    }
}
extension SSGC.StandardLibrarySources:SSGC.DocumentationSources
{
    var prefix:Symbol.FileBase? { nil }

    func indexStore(for swift:SSGC.Toolchain) throws -> (any Markdown.SwiftLanguage.IndexStore)?
    {
        nil
    }
}
