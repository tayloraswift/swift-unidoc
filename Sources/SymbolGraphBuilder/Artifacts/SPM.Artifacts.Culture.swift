import MarkdownABI
import MarkdownAST
import SymbolGraphLinker
import SymbolGraphParts
import SymbolGraphs
import Symbols
import System

extension SPM.Artifacts
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
extension SPM.Artifacts.Culture:Identifiable
{
    var id:Symbol.Module
    {
        self.module.id
    }
}
extension SPM.Artifacts.Culture
{
    func loadArticles(root:Symbol.FileBase) throws -> [MarkdownSourceFile]
    {
        //  Compute this once, since it’s used in the loop below.
        let bundle:Symbol.Module = self.module.id
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
            let id:Symbol.File = .init("\(relative)")

            print("Loading artifact: \(id)")

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

            print("Loading artifact: \($0)")

            do
            {
                return try .init(json: .init(utf8: try path.read()), id: $0)
            }
            catch let error
            {
                throw SPM.ArtifactError.init(underlying: error, path: path)
            }
        }
    }
}
