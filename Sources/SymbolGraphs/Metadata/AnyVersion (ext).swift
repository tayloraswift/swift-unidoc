import BSON
import SemanticVersions

extension AnyVersion:BSONEncodable
{
    public
    func encode(to field:inout BSON.FieldEncoder)
    {
        if  case .stable(let version) = self.canonical,
            case .release(build: nil) = version.suffix
        {
            version.number.encode(to: &field)
        }
        else
        {
            "\(self)".encode(to: &field)
        }
    }
}
extension AnyVersion:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue) throws
    {
        self = try bson.cast
        {
            switch $0
            {
            case .int64(let int64):
                .stable(.release(.init(rawValue: int64), build: nil))

            case .string(let utf8):
                .init(String.init(bson: utf8))

            default:
                nil
            }
        }
    }
}
