import MarkdownABI
import Symbols

extension SSGC
{
    protocol DocumentationSources
    {
        var cultures:[NominalSources] { get }
        var snippets:[LazyFile] { get }

        var prefix:Symbol.FileBase? { get }

        func indexStore(
            for swift:SSGC.Toolchain) throws -> (any Markdown.SwiftLanguage.IndexStore)?
    }
}
