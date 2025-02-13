import MarkdownABI
import MarkdownPluginSwift
import SymbolGraphs
import Symbols
import SystemIO

extension SSGC
{
    @_spi(testable) public
    struct BookSources
    {
        let modules:ModuleGraph
        private
        let root:Symbol.FileBase

        init(modules:ModuleGraph, root:Symbol.FileBase)
        {
            self.modules = modules
            self.root = root
        }
    }
}
extension SSGC.BookSources:SSGC.DocumentationSources
{
    @_spi(testable) public
    var symbols:[FilePath.Directory] { [] }

    @_spi(testable) public
    var prefix:Symbol.FileBase? { self.root }

    @_spi(testable) public
    func indexStore(for swift:SSGC.Toolchain) throws -> (any Markdown.SwiftLanguage.IndexStore)?
    {
        nil
    }
}
