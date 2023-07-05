import BSONDecoding
import UnidocRecords

@frozen public
struct Docpage:Equatable, Sendable
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
extension Docpage
{
    @frozen public
    enum CodingKeys:String
    {
        case principal
        case entourage
    }

    @inlinable public static
    subscript(key:CodingKeys) -> BSON.Key { .init(key) }
}
extension Docpage:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            principal: try bson[.principal].decode(),
            entourage: try bson[.entourage].decode())
    }
}
