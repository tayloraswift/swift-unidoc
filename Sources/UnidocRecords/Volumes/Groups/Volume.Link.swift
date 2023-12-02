import BSON
import Unidoc

extension Volume
{
    @frozen public
    enum Link:Equatable, Sendable
    {
        case scalar(Unidoc.Scalar)
        case text(String)
    }
}
extension Volume.Link:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        switch self
        {
        case .scalar(let scalar):
            scalar.encode(to: &field)
        case .text(let text):
            text.encode(to: &field)
        }
    }
}
extension Volume.Link:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue<some RandomAccessCollection<UInt8>>) throws
    {
        if  case .string(let utf8) = bson
        {
            self = .text(String.init(bson: utf8))
        }
        else
        {
            self = .scalar(try .init(bson: bson))
        }
    }
}
