import Availability
import BSONDecoding
import BSONEncoding

extension Availability.Range:BSONDecodable where Bound:BSONDecodable
{
    @inlinable public
    init<Bytes>(bson:BSON.AnyValue<Bytes>) throws
    {
        //  Use ``BSON.min`` instead of ``BSON.null``, decoding explicit nulls
        //  with sugared syntax is a footgun.
        if  case .min = bson
        {
            self = .unconditionally
        }
        else
        {
            self = .since(try .init(bson: bson))
        }
    }
}
extension Availability.Range:BSONEncodable, BSONFieldEncodable where Bound:BSONEncodable
{
    public
    func encode(to field:inout BSON.Field)
    {
        switch self
        {
        case .unconditionally:  BSON.Min.init().encode(to: &field)
        case .since(let bound): bound.encode(to: &field)
        }
    }
}
