import Availability
import BSON

extension Availability:BSONDocumentDecodable
{
    @inlinable public
    init<Bytes>(bson:BSON.DocumentDecoder<CodingKey, Bytes>) throws
    {
        self.init()

        for field:BSON.FieldDecoder<CodingKey, Bytes.SubSequence> in bson
        {
            switch field.key.domain
            {
            case .universal:
                self.universal = try field.decode()

            case .platform(let domain):
                self.platforms[domain] = try field.decode()

            case .agnostic(let domain):
                self.agnostic[domain] = try field.decode()
            }
        }
    }
}
extension Availability:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        for (domain, clauses):
        (
            Availability.AgnosticDomain,
            Availability.Clauses<Availability.AgnosticDomain>
        )   in self.agnostic
        {
            bson[.init(.agnostic(domain))] = clauses
        }
        for (domain, clauses):
        (
            Availability.PlatformDomain,
            Availability.Clauses<Availability.PlatformDomain>
        )   in self.platforms
        {
            bson[.init(.platform(domain))] = clauses
        }
        bson[.init(.universal)] = self.universal
    }
}
