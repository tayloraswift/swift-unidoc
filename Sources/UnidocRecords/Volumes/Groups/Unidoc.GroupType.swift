import BSON
import Unidoc

extension Unidoc
{
    /// Tag bits for ``Unidoc.Group.ID``.
    @frozen public
    enum GroupType:UInt32, Equatable, Sendable
    {
        case  conformers    = 0x00_000000

        case  polygon       = 0xC0_000000
        case `extension`    = 0xC2_000000
        case  topic         = 0xC3_000000
    }
}
extension Unidoc.GroupType
{
    @inlinable public
    func id(_ i:Int, in edition:Unidoc.Edition) -> Unidoc.Group.ID
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
