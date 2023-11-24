import BSONDecoding
import BSONEncoding
import SemanticVersions

extension SymbolGraphMetadata
{
    @frozen public
    struct PlatformRequirement:Identifiable, Equatable, Hashable, Sendable
    {
        public
        let id:Platform
        public
        let min:NumericVersion

        @inlinable public
        init(id:Platform, min:NumericVersion)
        {
            self.id = id
            self.min = min
        }
    }
}
extension SymbolGraphMetadata.PlatformRequirement
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case id = "I"
        case min = "L"
    }
}
extension SymbolGraphMetadata.PlatformRequirement:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.min] = self.min
    }
}
extension SymbolGraphMetadata.PlatformRequirement:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(), min: try bson[.min].decode())
    }
}
