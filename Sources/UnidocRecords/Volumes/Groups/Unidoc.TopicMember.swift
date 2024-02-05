import BSON
import Unidoc

extension Unidoc
{
    @frozen public
    enum TopicMember:Equatable, Sendable
    {
        case scalar(Unidoc.Scalar)
        case text(String)
    }
}
extension Unidoc.TopicMember:BSONEncodable
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
extension Unidoc.TopicMember:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue) throws
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
