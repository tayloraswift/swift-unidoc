import Availability
import BSON
import SemanticVersions

extension Availability.VersionRange:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue) throws
    {
        //  Use ``BSON.min`` instead of ``BSON.null``, decoding explicit nulls
        //  with sugared syntax is a footgun.
        switch bson
        {
        case .max:  self = .since(nil)
        case _:     self = .since(try NumericVersion.init(bson: bson))
        }
    }
}
extension Availability.VersionRange:BSONEncodable
{
    public
    func encode(to field:inout BSON.FieldEncoder)
    {
        switch self
        {
        case .since(nil):           BSON.Max.init().encode(to: &field)
        case .since(let bound?):    bound.encode(to: &field)
        }
    }
}
