import ModuleGraphs
import SymbolGraphParts
import System

extension Artifacts
{
    struct Culture
    {
        public
        let module:ModuleStack

        public
        let articles:[FilePath]
        public
        let parts:[FilePath]

        @inlinable public
        init(_ module:ModuleStack, articles:[FilePath], parts:[FilePath])
        {
            self.articles = articles
            self.parts = parts
            self.module = module
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
    init(sources:Artifacts.Sources, parts:[FilePath]) throws
    {
        if  parts.isEmpty,
            case .swift = sources.language
        {
            throw Artifacts.CultureError.empty(sources.module.id)
        }
        else
        {
            self.init(sources.module, articles: sources.articles, parts: parts)
        }
    }
}
extension Artifacts.Culture
{
    func load() throws -> [SymbolGraphPart]
    {
        try self.parts.map
        {
            do
            {
                return try .init(parsing: try $0.read([UInt8].self))
            }
            catch let error
            {
                throw ArtifactError.init(underlying: error, path: $0)
            }
        }
    }
}
