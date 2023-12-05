import BSON
import MongoDB

extension Mongo.UpdateEncoder
{
    @inlinable public mutating
    func replace(
        _ element:some BSONDocumentEncodable & Identifiable<some BSONEncodable>)
    {
        self.update(element, upsert: false)
    }

    @inlinable public mutating
    func upsert(
        _ element:some BSONDocumentEncodable & Identifiable<some BSONEncodable>)
    {
        self.update(element, upsert: true)
    }

    @inlinable internal mutating
    func update(
        _ element:some BSONDocumentEncodable & Identifiable<some BSONEncodable>,
        upsert:Bool)
    {
        self
        {
            $0[.upsert] = upsert
            $0[.q] = .init { $0["_id"] = element.id }
            $0[.u] = element
        }
    }
}
