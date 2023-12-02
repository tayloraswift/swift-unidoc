import BSON
import MongoQL
import SymbolGraphs
import Symbols
import UnidocRecords

extension Realm.SitemapQuery
{
    @frozen public
    struct Output:Sendable
    {
        public
        let package:Symbol.Package
        public
        let sitemap:Realm.Sitemap

        @inlinable public
        init(package:Symbol.Package, sitemap:Realm.Sitemap)
        {
            self.package = package
            self.sitemap = sitemap
        }
    }
}
extension Realm.SitemapQuery.Output:MongoMasterCodingModel
{
    public
    enum CodingKey:String, Sendable
    {
        case package
        case sitemap
    }
}
extension Realm.SitemapQuery.Output:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            package: try bson[.package].decode(),
            sitemap: try bson[.sitemap].decode())
    }
}
