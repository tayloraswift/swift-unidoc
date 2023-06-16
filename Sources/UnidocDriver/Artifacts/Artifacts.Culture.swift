import MarkdownABI
import MarkdownParsing
import MarkdownSemantics
import ModuleGraphs
import SymbolGraphParts
import Symbols
import System
import UnidocLinker

extension Artifacts
{
    struct Culture
    {
        let module:ModuleDetails

        let articles:[FilePath]
        let artifacts:FilePath
        let parts:[SymbolGraphPart.ID]

        init(_ module:ModuleDetails,
            articles:[FilePath],
            artifacts:FilePath,
            parts:[SymbolGraphPart.ID])
        {
            self.module = module

            self.articles = articles
            self.artifacts = artifacts
            self.parts = parts
        }
    }
}
extension Artifacts.Culture:Identifiable
{
    var id:ModuleIdentifier
    {
        self.module.id
    }
}
extension Artifacts.Culture
{
    func loadArticles(root:Repository.Root) throws -> [MarkdownFile]
    {
        let root:FilePath = .init(root.path).lexicallyNormalized()

        return try self.articles.sorted
        {
            $0.string < $1.string
        }
        .map
        {
            guard $0.components.starts(with: root.components)
            else
            {
                fatalError("Could not lexically rebase article file path '\($0)'")
            }

            let relative:FilePath = .init(root: nil,
                $0.components.dropFirst(root.components.count))
            let id:FileSymbol = .init("\(relative)")

            print("Loading artifact: \(id)")

            return .init(text: try $0.read(), name: $0.stem ?? "", id: id)
        }
    }
    func loadSymbols() throws -> [SymbolGraphPart]
    {
        try self.parts.sorted
        {
            $0.basename < $1.basename
        }
        .map
        {
            let path:FilePath = self.artifacts / "\($0)"

            print("Loading artifact: \($0)")

            do
            {
                return try .init(parsing: try path.read([UInt8].self), id: $0)
            }
            catch let error
            {
                throw ArtifactError.init(underlying: error, path: path)
            }
        }
    }
}
