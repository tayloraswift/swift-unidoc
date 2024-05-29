import MarkdownABI
import SymbolGraphs
import Symbols

extension SSGC
{
    /// Stores information about the source files for a package.
    struct SpecialSources
    {
        let cultures:[NominalSources]

        private
        init(cultures:[NominalSources])
        {
            self.cultures = cultures
        }
    }
}
extension SSGC.SpecialSources
{
    init(modules:consuming [SymbolGraph.Module])
    {
        self.init(cultures: modules.map(SSGC.NominalSources.init(toolchain:)))
    }
}
extension SSGC.SpecialSources:SSGC.DocumentationSources
{
    var snippets:[SSGC.LazyFile] { [] }
    var prefix:Symbol.FileBase? { nil }

    func indexStore(for swift:SSGC.Toolchain) throws -> (any Markdown.SwiftLanguage.IndexStore)?
    {
        nil
    }
}
