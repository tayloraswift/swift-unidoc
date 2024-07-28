import MarkdownABI
import SymbolGraphs
import Symbols

extension SSGC
{
    /// Stores information about the source files for a package.
    struct StandardLibrarySources
    {
        let cultures:[ModuleLayout]

        private
        init(cultures:[ModuleLayout])
        {
            self.cultures = cultures
        }
    }
}
extension SSGC.StandardLibrarySources
{
    init(modules:[SymbolGraph.Module])
    {
        self.init(cultures: modules.map(SSGC.ModuleLayout.init(toolchain:)))
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
