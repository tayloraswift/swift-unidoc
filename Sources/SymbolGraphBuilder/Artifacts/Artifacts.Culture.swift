import MarkdownABI
import MarkdownAST
import SymbolGraphLinker
import SymbolGraphParts
import SymbolGraphs
import Symbols
import System

extension Artifacts
{
    struct Culture
    {
        let module:SymbolGraph.Module

        let articles:[FilePath]
        let artifacts:FilePath
        let parts:[SymbolGraphPart.ID]

        init(_ module:SymbolGraph.Module,
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
    var id:Symbol.Module
    {
        self.module.id
    }
}
extension Artifacts.Culture
{
    func loadMarkdown(symbolizer:SPM.PathSymbolizer) throws -> [MarkdownSourceFile]
    {
        //  Compute this once, since it’s used in the loop below.
        let bundle:Symbol.Module = self.module.id

        return try self.articles.sorted
        {
            $0.string < $1.string
        }
        .map
        {
            let id:Symbol.File = symbolizer.rebase($0)

            print("Loading markdown: \(id)")

            return .init(bundle: bundle, path: id, text: try $0.read())
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

            print("Loading symbols: \($0)")

            do
            {
                return try .init(json: .init(utf8: try path.read()), id: $0)
            }
            catch let error
            {
                throw ArtifactError.init(underlying: error, path: path)
            }
        }
    }
}
