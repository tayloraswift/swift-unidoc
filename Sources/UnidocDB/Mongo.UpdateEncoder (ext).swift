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

    @inlinable mutating
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

    @inlinable mutating
    func update(field:Mongo.KeyPath,
        by index:Mongo.KeyPath,
        of key:some BSONEncodable,
        to value:some BSONEncodable)
    {
        self
        {
            $0[.hint] = .init { $0[index] = (+) }
            $0[.q] = .init { $0[index] = key }
            $0[.u] = .init
            {
                $0[.set] = .init { $0[field] = value }
            }
        }
    }
}
