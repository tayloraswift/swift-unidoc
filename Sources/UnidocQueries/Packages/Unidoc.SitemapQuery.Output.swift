import BSON
import MongoQL
import SymbolGraphs
import Symbols
import UnidocRecords

extension Unidoc.SitemapQuery
{
    @frozen public
    struct Output:Sendable
    {
        public
        let package:Symbol.Package
        public
        let sitemap:Unidoc.Sitemap

        @inlinable public
        init(package:Symbol.Package, sitemap:Unidoc.Sitemap)
        {
            self.package = package
            self.sitemap = sitemap
        }
    }
}
extension Unidoc.SitemapQuery.Output:Mongo.MasterCodingModel
{
    public
    enum CodingKey:String, Sendable
    {
        case package
        case sitemap
    }
}
extension Unidoc.SitemapQuery.Output:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            package: try bson[.package].decode(),
            sitemap: try bson[.sitemap].decode())
    }
}
