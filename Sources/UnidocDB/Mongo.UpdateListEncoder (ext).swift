import BSON
import MongoDB

extension Mongo.UpdateListEncoder
{
    @inlinable mutating
    func update(field:Mongo.AnyKeyPath,
        by index:Mongo.AnyKeyPath,
        of key:some BSONEncodable,
        to value:some BSONEncodable)
    {
        self
        {
            $0[.hint] = .init { $0[index] = (+) }
            $0[.q] { $0[index] = key }
            $0[.u] { $0[.set] { $0[field] = value } }
        }
    }
}
