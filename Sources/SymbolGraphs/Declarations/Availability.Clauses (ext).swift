import Availability
import BSONDecoding
import BSONEncoding

extension Availability.Clauses
{
    @frozen public
    enum CodingKeys:String
    {
        case unavailable = "U"
        case deprecated = "D"
        case introduced = "I"
        case obsoleted = "O"
        case renamed = "R"
        case message = "M"
    }
}
extension Availability.Clauses:BSONDocumentDecodable, BSONDocumentViewDecodable, BSONDecodable
    where   Domain.Unavailability:BSONDecodable,
            Domain.Deprecation:BSONDecodable,
            Domain.Bound:BSONDecodable
{
    @inlinable public
    init<Bytes>(bson:BSON.DocumentDecoder<CodingKeys, Bytes>) throws
    {
        self.init(unavailable: try bson[.unavailable]?.decode(),
            deprecated: try bson[.deprecated]?.decode(),
            introduced: try bson[.introduced]?.decode(),
            obsoleted: try bson[.obsoleted]?.decode(),
            renamed: try bson[.renamed]?.decode(),
            message: try bson[.message]?.decode())
    }
}
extension Availability.Clauses:BSONDocumentEncodable, BSONEncodable
    where   Domain.Unavailability:BSONEncodable,
            Domain.Deprecation:BSONEncodable,
            Domain.Bound:BSONEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.unavailable] = self.unavailable
        bson[.deprecated] = self.deprecated
        bson[.introduced] = self.introduced
        bson[.obsoleted] = self.obsoleted
        bson[.renamed] = self.renamed
        bson[.message] = self.message
    }
}
