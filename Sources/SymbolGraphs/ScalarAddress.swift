import BSONDecoding
import BSONEncoding

@frozen public
struct ScalarAddress
{
    public
    let value:Int32

    @inlinable public
    init(value:Int32)
    {
        self.value = value
    }
}
extension ScalarAddress:SymbolAddress
{
    public
    typealias Symbol = ScalarSymbol
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
}
