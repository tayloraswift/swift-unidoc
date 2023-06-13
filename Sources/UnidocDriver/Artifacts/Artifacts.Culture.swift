import MarkdownABI
import MarkdownParsing
import MarkdownSemantics
import ModuleGraphs
import SymbolGraphParts
import System

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
    func loadArticles() throws
    {
        _ = try self.articles.map
        {
            let documentation:MarkdownDocumentation = .init(parsing: try $0.read(),
                as: SwiftFlavoredMarkdown.self)
        }
    }
    func loadSymbols() throws -> [SymbolGraphPart]
    {
        try self.parts.map
        {
            let path:FilePath = self.artifacts / "\($0)"
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
