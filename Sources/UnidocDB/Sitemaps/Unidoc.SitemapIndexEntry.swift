import BSON
import MongoQL
import SymbolGraphs
import Symbols
import UnidocRecords

extension Unidoc
{
    /// A projected subset of the fields in ``Unidoc.Sitemap``, suitable for constructing a
    /// sitemap index file.
    @frozen public
    struct SitemapIndexEntry:Equatable, Sendable
    {
        public
        let modified:BSON.Millisecond?
        public
        let symbol:Symbol.Package

        @inlinable internal
        init(modified:BSON.Millisecond?, symbol:Symbol.Package)
        {
            self.modified = modified
            self.symbol = symbol
        }
    }
}
extension Unidoc.SitemapIndexEntry:Mongo.MasterCodingModel
{
    public
    enum CodingKey:String, Sendable
    {
        case modified = "M"
        case symbol = "Y"
    }
}
extension Unidoc.SitemapIndexEntry:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(modified: try bson[.modified]?.decode(), symbol: try bson[.symbol].decode())
    }
}
