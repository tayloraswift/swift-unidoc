import Availability
import BSONDecoding
import BSONEncoding
import SemanticVersions

extension Availability.AnyRange:BSONDecodable
{
    @inlinable public
    init<Bytes>(bson:BSON.AnyValue<Bytes>) throws
    {
        //  Use ``BSON.min`` instead of ``BSON.null``, decoding explicit nulls
        //  with sugared syntax is a footgun.
        switch bson
        {
        case .min:  self = .unconditionally
        case .max:  self = .since(nil)
        case _:     self = .since(try SemanticVersionMask.init(bson: bson))
        }
    }
}
extension Availability.AnyRange:BSONEncodable, BSONFieldEncodable
{
    public
    func encode(to field:inout BSON.Field)
    {
        switch self
        {
        case .unconditionally:      BSON.Min.init().encode(to: &field)
        case .since(nil):           BSON.Max.init().encode(to: &field)
        case .since(let bound?):    bound.encode(to: &field)
        }
    }
}
