
import BSONDecoding
import BSONEncoding
import SemanticVersions

extension AnyVersion:BSONEncodable
{
    public
    func encode(to field:inout BSON.Field)
    {
        switch self.canonical
        {
        case .stable(.release(let version)):
            version.encode(to: &field)

        case .unstable(let name):
            name.encode(to: &field)
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
                return .stable(.release(.init(rawValue: int64)))

            case .string(let utf8):
                return .init(String.init(bson: utf8))

            default:
                return nil
            }
        }
    }
}
