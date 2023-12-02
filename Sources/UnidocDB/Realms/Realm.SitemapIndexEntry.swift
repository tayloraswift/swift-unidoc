import BSON
import MongoQL
import SymbolGraphs
import Symbols
import UnidocRecords

extension Realm
{
    /// A projected subset of the fields in ``Realm.Sitemap``, suitable for constructing a
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
extension Realm.SitemapIndexEntry:MongoMasterCodingModel
{
    public
    enum CodingKey:String, Sendable
    {
        case modified = "M"
        case symbol = "Y"
    }
}
extension Realm.SitemapIndexEntry:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(modified: try bson[.modified]?.decode(), symbol: try bson[.symbol].decode())
    }
}
