
import BSONDecoding
import BSONEncoding
import SemanticVersions

extension SemanticRef:BSONEncodable
{
    public
    func encode(to field:inout BSON.Field)
    {
        switch self
        {
        case .version(let version):
            version.encode(to: &field)

        case .unstable(let name):
            name.encode(to: &field)
        }
    }
}
extension SemanticRef:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue<some RandomAccessCollection<UInt8>>) throws
    {
        self = try bson.cast
        {
            switch $0
            {
            case .int64(let int64):
                return SemanticVersion.init(rawValue: int64).map(Self.version(_:))

            case .string(let utf8):
                return .unstable(String.init(bson: utf8))

            default:
                return nil
            }
        }
    }
}
