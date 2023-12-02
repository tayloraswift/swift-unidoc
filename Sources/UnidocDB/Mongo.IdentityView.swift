import BSON
import MongoQL

extension Mongo
{
    /// An generic document model that can be used to extract the `_id` field of a document.
    ///
    /// TODO: This belongs in the MongoDB library.
    @frozen public
    struct IdentityView<ID>:Sendable where ID:Sendable, ID:BSONDecodable
    {
        public
        let id:ID

        @inlinable public
        init(id:ID)
        {
            self.id = id
        }
    }
}
extension Mongo.IdentityView:Identifiable where ID:Hashable
{
}
extension Mongo.IdentityView:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case id = "_id"
    }
}
extension Mongo.IdentityView:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode())
    }
}
