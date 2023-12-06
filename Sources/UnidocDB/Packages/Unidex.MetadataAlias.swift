import BSON
import MongoQL
import UnidocRecords

extension Unidex
{
    @frozen public
    struct MetadataAlias:Identifiable, Equatable, Sendable
    {
        public
        let id:String
        public
        let realm:Unidex

        @inlinable public
        init(id:String, realm:Unidex)
        {
            self.id = id
            self.realm = realm
        }
    }
}
extension Unidex.MetadataAlias:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case id = "_id"
        case realm = "r"
    }
}
extension Unidex.MetadataAlias:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.realm] = self.realm
    }
}
extension Unidex.MetadataAlias:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(), realm: try bson[.realm].decode())
    }
}
