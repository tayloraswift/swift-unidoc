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
        let masters:[Record.Master]
        public
        let zone:Record.Zone

        @inlinable internal
        init(masters:[Record.Master], zone:Record.Zone)
        {
            self.masters = masters
            self.zone = zone
        }
    }
}
extension ThinQuery.Output:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, CaseIterable
    {
        case masters = "M"
        case zone = "Z"
    }
}
extension ThinQuery.Output:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(masters: try bson[.masters].decode(), zone: try bson[.zone].decode())
    }
}
