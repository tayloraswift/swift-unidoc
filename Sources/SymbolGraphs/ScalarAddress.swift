import BSONDecoding
import BSONEncoding

/// An ``Int32`` that is statically known to be representable
/// as a 24-bit unsigned integer.
@frozen public
struct ScalarAddress
{
    public
    let value:Int32

    @inlinable public
    init?(exactly int32:Int32)
    {
        if  0 ... 0x00_ff_ff_ff ~= int32
        {
            self.value = int32
        }
        else
        {
            return nil
        }
    }
}
extension ScalarAddress:SymbolAddress
{
    public
    typealias Identity = ScalarSymbol
}
extension ScalarAddress
{
    /// Concatenates the bits of the two scalar addresses into a 64-bit integer,
    /// storing the bits of the first operand in the most-significant bits of
    /// the result.
    static
    func | (high:Self, low:Self) -> Int64
    {
        .init(high.value) << 32 | .init(low.value)
    }
}
extension ScalarAddress:BSONDecodable, BSONEncodable
{
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
