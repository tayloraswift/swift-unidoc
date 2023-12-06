import BSON
import MongoQL
import Unidoc
import UnidocRecords

extension Unidex
{
    @frozen public
    struct Realm:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Realm

        public
        var symbol:String

        @inlinable public
        init(id:Unidoc.Realm, symbol:String)
        {
            self.id = id
            self.symbol = symbol
        }
    }
}
extension Unidex.Realm:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case id = "_id"
        case symbol = "symbol"
    }
}
extension Unidex.Realm:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.symbol] = self.symbol
    }
}
extension Unidex.Realm:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(),
            symbol: try bson[.symbol].decode())
    }
}
