import BSON
import Symbols

extension SymbolGraphMetadata
{
    @frozen public
    struct Product:Equatable, Hashable, Sendable
    {
        public
        let name:String
        public
        let type:ProductType
        public
        var dependencies:[Symbol.Product]
        public
        var cultures:[Int]

        @inlinable public
        init(name:String, type:ProductType, dependencies:[Symbol.Product], cultures:[Int])
        {
            self.name = name
            self.type = type
            self.dependencies = dependencies
            self.cultures = cultures
        }
    }
}
extension SymbolGraphMetadata.Product
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case name = "N"
        case type = "T"
        case dependencies = "P"
        case cultures = "C"
    }
}
extension SymbolGraphMetadata.Product:BSONDocumentEncodable
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
extension SymbolGraphMetadata.Product:BSONDocumentDecodable
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
