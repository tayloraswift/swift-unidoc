import BSONDecoding
import BSONEncoding
import Generics

extension GenericSignature
{
    @frozen public
    enum CodingKeys:String
    {
        case constraints = "C"
        case parameters = "P"
    }
}
extension GenericSignature:BSONDocumentEncodable, BSONEncodable, BSONFieldEncodable
    where TypeReference:BSONEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.constraints] = self.constraints.isEmpty ? nil : self.constraints
        bson[.parameters] = self.parameters.isEmpty ? nil : self.parameters
    }
}
extension GenericSignature:BSONDocumentDecodable, BSONDecodable, BSONDocumentViewDecodable
    where TypeReference:BSONDecodable
{
    @inlinable public
    init<Bytes>(bson:BSON.DocumentDecoder<CodingKeys, Bytes>) throws
    {
        self.init(
            constraints: try bson[.constraints]?.decode() ?? [],
            parameters: try bson[.parameters]?.decode() ?? [])
    }
}
