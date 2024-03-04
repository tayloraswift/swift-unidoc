import BSON
import Unidoc

extension Unidoc
{
    /// Tag bits for ``Unidoc.Group``.
    @frozen public
    enum GroupType:UInt32, Equatable, Sendable
    {
        case  conformer     = 0x00_000000

        case  curator       = 0xC0_000000
        case `extension`    = 0xC2_000000
        /// Deprecated, do not use anymore.
        case  topic         = 0xC3_000000
        case  intrinsic     = 0xC4_000000
    }
}
extension Unidoc.GroupType
{
    @inlinable public
    func id(_ i:Int, in edition:Unidoc.Edition) -> Unidoc.Group
    {
        precondition(0 ... 0x00_FFFFFF ~= i)
        let citizen:Int32 = .init(bitPattern: self.rawValue) | Int32.init(i)
        return .init(rawValue: edition + citizen)
    }
}
extension Unidoc.GroupType
{
    @inlinable internal static
    func of(_ scalar:Int32) -> Self?
    {
        self.init(rawValue: 0xFF_000000 & UInt32.init(bitPattern: scalar))
    }
}
