import BSON
import MongoQL
import SymbolGraphs
import Symbols
import UnidocRecords

extension Unidex.SitemapQuery
{
    @frozen public
    struct Output:Sendable
    {
        public
        let package:Symbol.Package
        public
        let sitemap:Unidex.Sitemap

        @inlinable public
        init(package:Symbol.Package, sitemap:Unidex.Sitemap)
        {
            self.package = package
            self.sitemap = sitemap
        }
    }
}
extension Unidex.SitemapQuery.Output:MongoMasterCodingModel
{
    public
    enum CodingKey:String, Sendable
    {
        case package
        case sitemap
    }
}
extension Unidex.SitemapQuery.Output:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            package: try bson[.package].decode(),
            sitemap: try bson[.sitemap].decode())
    }
}
