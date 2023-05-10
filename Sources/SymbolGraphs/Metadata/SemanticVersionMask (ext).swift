import BSONDecoding
import BSONEncoding
import SemanticVersions

extension SemanticVersionMask
{
    /// The precision tag used by this type’s BSON ABI. It inhabits the
    /// least-significant bits of a ``UInt64``, and starts counting from
    /// `1` to prevent generating an all-zero bit pattern.
    @frozen public
    enum Precision:UInt64
    {
        case major = 1
        case minor = 2
        case patch = 3
    }
}
extension SemanticVersionMask:RawRepresentable
{
    @inlinable public
    var rawValue:UInt64
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
    init?(rawValue:UInt64)
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
