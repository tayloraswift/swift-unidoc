import BSONDecoding
import BSONEncoding
import MongoQL
import Unidoc
import UnidocRecords

extension UnidocDatabase.DocsFeed
{
    @frozen public
    struct Activity<Volume>:Identifiable, Sendable
        where   Volume:BSONEncodable,
                Volume:BSONDecodable,
                Volume:Sendable
    {
        /// In retrospect, this was a truly awful choice of `_id` key.
        public
        let id:BSON.Millisecond

        public
        let volume:Volume

        @inlinable public
        init(discovered id:BSON.Millisecond, volume:Volume)
        {
            self.id = id
            self.volume = volume
        }
    }
}
extension UnidocDatabase.DocsFeed.Activity:MongoMasterCodingModel
{
    public
    enum CodingKey:String
    {
        case id = "_id"
        case volume = "V"
    }
}
extension UnidocDatabase.DocsFeed.Activity:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.volume] = self.volume
    }
}
extension UnidocDatabase.DocsFeed.Activity:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(discovered: try bson[.id].decode(), volume: try bson[.volume].decode())
    }
}
