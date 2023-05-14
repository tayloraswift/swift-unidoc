import BSONDecoding
import BSONEncoding
import SemanticVersions

extension SemanticVersion:RawRepresentable
{
    @inlinable public
    var rawValue:Int64
    {

                .init(major) << 48 |
                .init(minor) << 32 |
                .init(patch) << 16
    }
    @inlinable public
    init?(rawValue:Int64)
    {
        let major:UInt16 = .init(truncatingIfNeeded: rawValue >> 48)
        let minor:UInt16 = .init(truncatingIfNeeded: rawValue >> 32)
        let patch:UInt16 = .init(truncatingIfNeeded: rawValue >> 16)
        self = .v(major, minor, patch)
    }
}
extension SemanticVersion:BSONDecodable, BSONEncodable
{
}
