import BSONDecoding
import BSONEncoding
import MongoQL
import Unidoc
import UnidocRecords

extension UnidocDatabase
{
    @frozen public
    struct DocsActivity<Volume>:Identifiable, Sendable
        where   Volume:BSONEncodable,
                Volume:BSONDecodable,
                Volume:Sendable
    {
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
extension UnidocDatabase.DocsActivity:MongoMasterCodingModel
{
    public
    enum CodingKey:String
    {
        case id = "_id"
        case volume = "V"
    }
}
extension UnidocDatabase.DocsActivity:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.volume] = self.volume
    }
}
extension UnidocDatabase.DocsActivity:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(discovered: try bson[.id].decode(), volume: try bson[.volume].decode())
    }
}
