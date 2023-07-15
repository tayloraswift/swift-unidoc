import BSONDecoding
import BSONEncoding
import ModuleGraphs

extension ProductDetails
{
    @frozen public
    enum CodingKey:String
    {
        case name = "N"
        case type = "T"
        case dependencies = "P"
        case cultures = "C"
    }
}
extension ProductDetails:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.name] = self.name
        bson[.type] = self.type
        bson[.dependencies] = self.dependencies.isEmpty ? nil : self.dependencies
        bson[.cultures] = self.cultures
    }
}
extension ProductDetails:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            name: try bson[.name].decode(),
            type: try bson[.type].decode(),
            dependencies: try bson[.dependencies]?.decode() ?? [],
            cultures: try bson[.cultures].decode())
    }
}
