
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
        case .stable(.release(let version, build: nil)):
            version.encode(to: &field)

        case let other:
            "\(other)".encode(to: &field)
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
                return .stable(.release(.init(rawValue: int64), build: nil))

            case .string(let utf8):
                return .init(String.init(bson: utf8))

            default:
                return nil
            }
        }
    }
}
