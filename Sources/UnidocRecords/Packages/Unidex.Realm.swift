import BSON

extension Unidex
{
    @frozen public
    struct Realm:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Realm

        public
        var symbol:String
        public
        var hidden:Bool

        @inlinable public
        init(id:Unidoc.Realm, symbol:String, hidden:Bool)
        {
            self.id = id
            self.symbol = symbol
            self.hidden = hidden
        }
    }
}
extension Unidex.Realm
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case id = "_id"
        case symbol = "symbol"
        case hidden = "hidden"
    }
}
extension Unidex.Realm:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.symbol] = self.symbol
        bson[.hidden] = self.hidden
    }
}
extension Unidex.Realm:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(),
            symbol: try bson[.symbol].decode(),
            hidden: try bson[.hidden].decode())
    }
}
