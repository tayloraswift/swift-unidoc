import BSONDecoding
import BSONEncoding
import ModuleGraphs

extension ModuleDetails
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case name = "N"
        case type = "T"
        case dependencies_products = "P"
        case dependencies_modules = "D"
        case location = "L"
    }
}
extension ModuleDetails:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
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
extension ModuleDetails:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
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
