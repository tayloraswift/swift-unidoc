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
    let snippets:[Snippet]
    var root:Symbol.FileBase?

    init(cultures:[Culture], snippets:[Snippet], root:Symbol.FileBase? = nil)
    {
        self.cultures = cultures
        self.snippets = snippets
        self.root = root
    }
}
extension Artifacts
{
    func loadMarkdown() throws -> [[MarkdownSourceFile]]
    {
        guard
        let root:Symbol.FileBase = self.root
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

            return try $0.loadMarkdown(root: root)
        }
    }

    func loadSnippets() throws -> [SnippetSourceFile]
    {
        try self.snippets.map
        {
            print("Loading snippet: \($0.name)")
            return .init(name: $0.name, text: try $0.location.read())
        }
    }
}
