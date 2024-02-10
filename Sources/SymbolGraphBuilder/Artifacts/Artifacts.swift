import PackageGraphs
import PackageMetadata
import SymbolGraphParts
import SymbolGraphLinker
import SymbolGraphs
import Symbols
import System

struct Artifacts
{
    let cultures:[Culture]
    let snippets:[SPM.SnippetSources]

    var root:Symbol.FileBase?

    init(cultures:[Artifacts.Culture],
        snippets:[SPM.SnippetSources],
        root:Symbol.FileBase? = nil)
    {
        self.cultures = cultures
        self.snippets = snippets
        self.root = root
    }
}
extension Artifacts
{
    private
    var symbolizer:SPM.PathSymbolizer? { self.root.map(SPM.PathSymbolizer.init(root:)) }
}
extension Artifacts
{
    func loadMarkdown() throws -> [[MarkdownSourceFile]]
    {
        guard
        let symbolizer:SPM.PathSymbolizer = self.symbolizer
        else
        {
            return []
        }

        return try self.cultures.map
        {
            switch $0.module.type
            {
            //  Only load markdown supplements for these module types.
            case .executable:   break
            case .regular:      break
            case .macro:        break
            case .plugin:       break
            default:            return []
            }

            return try $0.loadMarkdown(symbolizer: symbolizer)
        }
    }

    func loadSnippets() throws -> [SwiftSourceFile]
    {
        guard
        let symbolizer:SPM.PathSymbolizer = self.symbolizer
        else
        {
            return []
        }

        return try self.snippets.map
        {
            let id:Symbol.File = symbolizer.rebase($0.location)

            print("Loading snippet: \(id)")

            return .init(name: $0.name, path: id, utf8: try $0.location.read())
        }
    }
}
