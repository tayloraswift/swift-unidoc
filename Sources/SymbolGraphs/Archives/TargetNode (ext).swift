import BSONDecoding
import BSONEncoding
import ModuleGraphs

extension TargetNode
{
    @frozen public
    enum CodingKeys:String
    {
        case name = "N"
        case type = "T"
        case dependencies_products = "P"
        case dependencies_modules = "D"
        case location = "L"
    }
}
extension TargetNode:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.name] = self.name
        bson[.type] = self.type
        bson[.dependencies_products] =
            self.dependencies.products.isEmpty ? nil :
            self.dependencies.products
        bson[.dependencies_modules] =
            self.dependencies.modules.isEmpty ? nil :
            self.dependencies.modules
        bson[.location] = self.location
    }
}
extension TargetNode:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            name: try bson[.name].decode(),
            type: try bson[.type].decode(),
            dependencies: .init(
                products: try bson[.dependencies_products]?.decode() ?? [],
                modules: try bson[.dependencies_modules]?.decode() ?? []),
            location: try bson[.location]?.decode())
    }
}
