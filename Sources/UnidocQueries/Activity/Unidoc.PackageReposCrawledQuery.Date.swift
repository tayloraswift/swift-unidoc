import BSON
import MongoQL
import UnidocDB

extension Unidoc.PackageReposCrawledQuery
{
    @frozen public
    struct Date
    {
        public
        let window:Unidoc.CrawlingWindow
        public
        let repos:Int

        @inlinable internal
        init(window:Unidoc.CrawlingWindow, repos:Int)
        {
            self.window = window
            self.repos = repos
        }
    }
}
extension Unidoc.PackageReposCrawledQuery.Date:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case window = "W"
        case repos = "R"
    }
}
extension Unidoc.PackageReposCrawledQuery.Date:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(window: try bson[.window].decode(), repos: try bson[.repos].decode())
    }
}
