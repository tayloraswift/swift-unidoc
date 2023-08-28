import BSONDecoding
import MongoSchema
import UnidocSelectors
import UnidocRecords

extension ThinQuery
{
    @frozen public
    struct Output:Equatable, Sendable
    {
        public
        let masters:[Volume.Master]
        public
        let names:Volume.Names

        @inlinable internal
        init(masters:[Volume.Master], names:Volume.Names)
        {
            self.masters = masters
            self.names = names
        }
    }
}
extension ThinQuery.Output:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, CaseIterable
    {
        case masters = "M"
        case names = "Z"
    }
}
extension ThinQuery.Output:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(masters: try bson[.masters].decode(), names: try bson[.names].decode())
    }
}
