import MarkdownABI
import SymbolGraphs
import Symbols
import SystemIO

extension SSGC
{
    /// Stores information about the source files for a package.
    struct StandardLibrarySources
    {
        let cultures:[ModuleLayout]
        let symbols:[FilePath.Directory]

        private
        init(cultures:[ModuleLayout], symbols:[FilePath.Directory])
        {
            self.cultures = cultures
            self.symbols = symbols
        }
    }
}
extension SSGC.StandardLibrarySources
{
    init(modules:[SymbolGraph.Module], symbols:[FilePath.Directory])
    {
        self.init(cultures: modules.map(SSGC.ModuleLayout.init(toolchain:)), symbols: symbols)
    }
}
extension SSGC.StandardLibrarySources:SSGC.DocumentationSources
{
    var snippets:[SSGC.LazyFile] { [] }
    var prefix:Symbol.FileBase? { nil }

    func constituents(of layout:__owned SSGC.ModuleLayout) throws -> [SSGC.ModuleLayout]
    {
        layout.dependencies.modules.map { self.cultures[$0] } + [layout]
    }

    func indexStore(for swift:SSGC.Toolchain) throws -> (any Markdown.SwiftLanguage.IndexStore)?
    {
        nil
    }
}
