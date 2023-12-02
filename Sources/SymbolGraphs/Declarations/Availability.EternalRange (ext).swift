import Availability
import BSON

extension Availability.EternalRange:BSONDecodable
{
    @inlinable public
    init<Bytes>(bson:BSON.AnyValue<Bytes>) throws
    {
        let _:BSON.Min = try .init(bson: bson)
        self = .unconditionally
    }
}
extension Availability.EternalRange:BSONEncodable
{
    public
    func encode(to field:inout BSON.FieldEncoder)
    {
        BSON.Min.init().encode(to: &field)
    }
}
