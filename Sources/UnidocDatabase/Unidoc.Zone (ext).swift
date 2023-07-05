import BSONDecoding
import BSONEncoding
import Unidoc

extension Unidoc.Zone:RawRepresentable
{
    @inlinable public
    init(rawValue:Int64)
    {
        self.init(
            package: Int32.init(rawValue >> 32),
            version: Int32.init(truncatingIfNeeded: rawValue))
    }
    @inlinable public
    var rawValue:Int64
    {
        Int64.init(self.package) << 32 | Int64.init(UInt32.init(bitPattern: self.version))
    }
}
extension Unidoc.Zone:BSONDecodable, BSONEncodable
{
}
