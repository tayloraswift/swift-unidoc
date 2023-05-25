import BSONDecoding
import BSONEncoding
import ModuleGraphs

extension PlatformRequirement
{
    @frozen public
    enum CodingKeys:String
    {
        case id = "I"
        case min = "L"
    }
}
extension PlatformRequirement:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.id] = self.id
        bson[.min] = self.min
    }
}
extension PlatformRequirement:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(), min: try bson[.min].decode())
    }
}
