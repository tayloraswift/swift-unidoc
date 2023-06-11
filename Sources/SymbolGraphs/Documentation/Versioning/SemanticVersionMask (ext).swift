import BSONDecoding
import BSONEncoding
import SemanticVersions

extension SemanticVersionMask:RawRepresentable
{
    @inlinable public
    var rawValue:Int64
    {
        switch self
        {
        case .major(let major):
            return Precision.major.rawValue |
                .init(major) << 48

        case .minor(let major, let minor):
            return Precision.minor.rawValue |
                .init(major) << 48 |
                .init(minor) << 32

        case .patch(let major, let minor, let patch):
            return Precision.patch.rawValue |
                .init(major) << 48 |
                .init(minor) << 32 |
                .init(patch) << 16
        }
    }
    @inlinable public
    init?(rawValue:Int64)
    {
        let major:UInt16 = .init(truncatingIfNeeded: rawValue >> 48)
        let minor:UInt16 = .init(truncatingIfNeeded: rawValue >> 32)
        let patch:UInt16 = .init(truncatingIfNeeded: rawValue >> 16)
        switch Precision.init(rawValue: rawValue & 0xff)
        {
        case nil:       return nil
        case .major?:   self = .major(major)
        case .minor?:   self = .minor(major, minor)
        case .patch?:   self = .patch(major, minor, patch)
        }
    }
}
extension SemanticVersionMask:BSONDecodable, BSONEncodable
{
}
