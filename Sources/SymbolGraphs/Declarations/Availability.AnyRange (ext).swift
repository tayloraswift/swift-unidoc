import Availability
import BSON
import SemanticVersions

extension Availability.AnyRange: BSONDecodable {
    @inlinable public init(bson: BSON.AnyValue) throws {
        //  Use ``BSON.min`` instead of ``BSON.null``, decoding explicit nulls
        //  with sugared syntax is a footgun.
        switch bson {
        case .min:  self = .unconditionally
        case .max:  self = .since(nil)
        case _:     self = .since(try NumericVersion.init(bson: bson))
        }
    }
}
extension Availability.AnyRange: BSONEncodable {
    public func encode(to field: inout BSON.FieldEncoder) {
        switch self {
        case .unconditionally:      BSON.Min.init().encode(to: &field)
        case .since(nil):           BSON.Max.init().encode(to: &field)
        case .since(let bound?):    bound.encode(to: &field)
        }
    }
}
