import Availability
import BSONDecoding
import BSONEncoding

extension Availability.EternalRange:BSONDecodable
{
    @inlinable public
    init<Bytes>(bson:BSON.AnyValue<Bytes>) throws
    {
        let _:BSON.Min = try .init(bson: bson)
        self = .unconditionally
    }
}
extension Availability.EternalRange:BSONEncodable, BSONFieldEncodable
{
    public
    func encode(to field:inout BSON.Field)
    {
        BSON.Min.init().encode(to: &field)
    }
}
