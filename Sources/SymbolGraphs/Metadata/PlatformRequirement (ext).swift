import BSONDecoding
import BSONEncoding
import ModuleGraphs

extension PlatformRequirement
{
    @frozen public
    enum CodingKey:String
    {
        case id = "I"
        case min = "L"
    }
}
extension PlatformRequirement:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.min] = self.min
    }
}
extension PlatformRequirement:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(), min: try bson[.min].decode())
    }
}
