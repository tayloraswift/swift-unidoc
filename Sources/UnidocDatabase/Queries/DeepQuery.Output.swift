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
        let entourage:[Record.Master]

        @inlinable public
        init(principal:[Principal], entourage:[Record.Master])
        {
            self.principal = principal
            self.entourage = entourage
        }
    }
}
extension DeepQuery.Output
{
    @frozen public
    enum CodingKeys:String
    {
        case principal
        case entourage
    }

    static
    subscript(key:CodingKeys) -> BSON.Key { .init(key) }
}
extension DeepQuery.Output:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            principal: try bson[.principal].decode(),
            entourage: try bson[.entourage].decode())
    }
}
