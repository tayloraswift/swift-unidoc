import BSON
import MongoDB

extension Mongo.UpdateStatement
{
    @inlinable public static
    func replace(
        _ element:some BSONDocumentEncodable & Identifiable<some BSONEncodable>) -> Self
    {
        .update(element, upsert: false)
    }

    @inlinable public static
    func upsert(
        _ element:some BSONDocumentEncodable & Identifiable<some BSONEncodable>) -> Self
    {
        .update(element, upsert: true)
    }

    @inlinable internal static
    func update(
        _ element:some BSONDocumentEncodable & Identifiable<some BSONEncodable>,
        upsert:Bool) -> Self
    {
        .init
        {
            $0[.upsert] = upsert
            $0[.q] = .init { $0["_id"] = element.id }
            $0[.u] = element
        }
    }
}
