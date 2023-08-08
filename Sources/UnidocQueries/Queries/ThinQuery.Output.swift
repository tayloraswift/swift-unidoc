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
        let trunk:Record.Trunk

        @inlinable internal
        init(masters:[Record.Master], trunk:Record.Trunk)
        {
            self.masters = masters
            self.trunk = trunk
        }
    }
}
extension ThinQuery.Output:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, CaseIterable
    {
        case masters = "M"
        case trunk = "T"
    }
}
extension ThinQuery.Output:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(masters: try bson[.masters].decode(), trunk: try bson[.trunk].decode())
    }
}
