import BSONDecoding
import MongoSchema
import UnidocRecords
import UnidocSelectors

extension WideQuery
{
    @frozen public
    struct Output:Equatable, Sendable
    {
        public
        let principal:Principal?
        public
        let secondary:[Volume.Vertex]
        public
        let names:[Volume.Meta]

        @inlinable public
        init(principal:Principal?,
            secondary:[Volume.Vertex],
            names:[Volume.Meta])
        {
            self.principal = principal
            self.secondary = secondary
            self.names = names
        }
    }
}
extension WideQuery.Output:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String
    {
        case principal
        case secondary
        case names
    }
}
extension WideQuery.Output:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            principal: try bson[.principal]?.decode(),
            secondary: try bson[.secondary].decode(),
            names: try bson[.names].decode())
    }
}
