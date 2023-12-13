import BSON
import MongoQL
import Unidoc
import UnidocRecords

extension Unidex
{
    @available(*, deprecated, renamed: "Unidoc.RealmMetadata")
    public
    typealias Realm = Unidoc.RealmMetadata
}
extension Unidoc
{
    @frozen public
    struct RealmMetadata:Identifiable, Equatable, Sendable
    {
        public
        let id:Realm

        public
        var symbol:String

        @inlinable public
        init(id:Realm, symbol:String)
        {
            self.id = id
            self.symbol = symbol
        }
    }
}
extension Unidoc.RealmMetadata:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case id = "_id"
        case symbol = "symbol"
    }
}
extension Unidoc.RealmMetadata:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.symbol] = self.symbol
    }
}
extension Unidoc.RealmMetadata:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(),
            symbol: try bson[.symbol].decode())
    }
}
