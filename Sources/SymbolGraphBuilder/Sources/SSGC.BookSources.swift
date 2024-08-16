import MarkdownABI
import MarkdownPluginSwift
import SymbolGraphs
import Symbols
import System

extension SSGC
{
    @_spi(testable) public
    struct BookSources
    {
        private(set)
        var cultures:[ModuleLayout]
        let root:PackageRoot

        private
        init(cultures:[ModuleLayout] = [], root:PackageRoot)
        {
            self.cultures = cultures
            self.root = root
        }
    }
}
extension SSGC.BookSources
{
    init(scanning location:FilePath.Directory) throws
    {
        self.init(root: .init(normalizing: location))

        var bundles:[(FilePath.Directory, FilePath.Component)] = []
        try location.walk
        {
            switch $1.extension
            {
            case "docc"?, "unidoc"?:
                bundles.append(($0, $1))
                return false

            default:
                return ($0 / $1).exists()
            }
        }

        for (parent, bundle):(FilePath.Directory, FilePath.Component) in bundles
        {
            let module:SymbolGraph.Module = .init(name: bundle.stem, type: .book)
            self.cultures.append(try .init(package: self.root,
                bundle: parent / bundle,
                module: module))
        }
    }
}
extension SSGC.BookSources:SSGC.DocumentationSources
{
    @_spi(testable) public
    var snippets:[SSGC.LazyFile] { [] }

    @_spi(testable) public
    var symbols:[FilePath.Directory] { [] }

    @_spi(testable) public
    var prefix:Symbol.FileBase? { .init(self.root.location.path.string) }


    @_spi(testable) public
    func constituents(of module:__owned SSGC.ModuleLayout) throws -> [SSGC.ModuleLayout]
    {
        [module]
    }

    @_spi(testable) public
    func indexStore(for swift:SSGC.Toolchain) throws -> (any Markdown.SwiftLanguage.IndexStore)?
    {
        nil
    }
}
