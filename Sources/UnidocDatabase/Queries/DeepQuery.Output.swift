import BSONDecoding
import UnidocRecords

extension DeepQuery
{
    @frozen public
    struct Output:Equatable, Sendable
    {
        public
        let principal:[Principal]
        public
        let secondary:[Record.Master]
        public
        let zones:[Record.Zone]

        @inlinable public
        init(principal:[Principal], secondary:[Record.Master], zones:[Record.Zone])
        {
            self.principal = principal
            self.secondary = secondary
            self.zones = zones
        }
    }
}
extension DeepQuery.Output
{
    @frozen public
    enum CodingKey:String
    {
        case principal
        case secondary
        case zones
    }

    static
    subscript(key:CodingKey) -> BSON.Key { .init(key) }
}
extension DeepQuery.Output:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            principal: try bson[.principal].decode(),
            secondary: try bson[.secondary].decode(),
            zones: try bson[.zones].decode())
    }
}
