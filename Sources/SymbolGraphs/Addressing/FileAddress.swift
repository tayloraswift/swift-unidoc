import BSONDecoding
import BSONEncoding
import Symbols

@frozen public
struct FileAddress
{
    public
    let value:Int32

    @inlinable public
    init(value:Int32)
    {
        self.value = value
    }
}
extension FileAddress:SymbolAddress
{
    @inlinable public
    init(exactly int32:Int32)
    {
        self.init(value: int32)
    }
}
extension FileAddress
{
    /// Concatenates the bits of the two scalar addresses into a 64-bit integer,
    /// storing the bits of the first operand in the most-significant bits of
    /// the result.
    static
    func | (high:Self, low:SourcePosition) -> Int64
    {
        .init(high.value) << 32 | .init(low.rawValue)
    }
}
extension FileAddress:BSONDecodable, BSONEncodable
{
}
extension FileAddress:CustomStringConvertible
{
}
