import Availability
import BSONDecoding
import BSONEncoding

extension Availability.Range:BSONDecodable where Bound:BSONDecodable
{
    @inlinable public
    init<Bytes>(bson:BSON.AnyValue<Bytes>) throws
    {
        if  let bound:Bound = try .init(bson: bson)
        {
            self = .since(bound)
        }
        else
        {
            self = .unconditionally
        }
    }
}
extension Availability.Range:BSONEncodable, BSONFieldEncodable where Bound:BSONEncodable
{
    public
    func encode(to field:inout BSON.Field)
    {
        let representation:Bound?
        switch self
        {
        case .unconditionally:  representation = nil
        case .since(let bound): representation = bound
        }
        representation.encode(to: &field)
    }
}
