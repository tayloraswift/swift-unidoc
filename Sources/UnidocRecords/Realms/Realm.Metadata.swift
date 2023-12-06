import BSON

extension Realm
{
    @frozen public
    struct Metadata:Identifiable, Equatable, Sendable
    {
        public
        let id:Realm

        public
        var symbol:String
        public
        var hidden:Bool

        @inlinable public
        init(id:Realm, symbol:String, hidden:Bool)
        {
            self.id = id
            self.symbol = symbol
            self.hidden = hidden
        }
    }
}
extension Realm.Metadata
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case id = "_id"
        case symbol = "symbol"
        case hidden = "hidden"
    }
}
extension Realm.Metadata:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.symbol] = self.symbol
        bson[.hidden] = self.hidden
    }
}
extension Realm.Metadata:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(),
            symbol: try bson[.symbol].decode(),
            hidden: try bson[.hidden].decode())
    }
}
