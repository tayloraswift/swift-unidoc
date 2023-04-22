/// A ``UInt32`` that is statically known to be representable
/// as a 24-bit unsigned integer.
@frozen public
struct ScalarAddress
{
    public
    let value:UInt32

    @inlinable public
    init?(exactly uint32:UInt32)
    {
        if uint32 & 0xff_00_00_00 != 0
        {
            return nil
        }

        self.value = uint32
    }
}
extension ScalarAddress:SymbolAddress
{
    public
    typealias Identity = ScalarIdentifier
}
extension ScalarAddress:CustomStringConvertible
{
    public
    var description:String
    {
        let hex:String = .init(self.value, radix: 16)
        return "0x\(String.init(repeating: "0", count: 6 - hex.count))"
    }
}
