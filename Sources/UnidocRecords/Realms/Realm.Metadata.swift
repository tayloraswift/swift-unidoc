import BSON

extension Realm
{
    @frozen public
    struct Metadata:Identifiable, Equatable, Sendable
    {
        public
        let id:Realm

        public
        let name:String

        @inlinable public
        init(id:Realm, name:String)
        {
            self.id = id
            self.name = name
        }
    }
}
extension Realm.Metadata
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case id = "_id"
        case name = "name"
    }
}
extension Realm.Metadata:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.name] = self.name
    }
}
extension Realm.Metadata:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(), name: try bson[.name].decode())
    }
}
