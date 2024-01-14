
import BSON
import SemanticVersions

extension AnyVersion:BSONEncodable
{
    public
    func encode(to field:inout BSON.FieldEncoder)
    {
        if  case .stable(.release(let version, build: nil)) = self.canonical
        {
            version.encode(to: &field)
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
    init(bson:BSON.AnyValue<some RandomAccessCollection<UInt8>>) throws
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
