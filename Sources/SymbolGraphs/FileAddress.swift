import BSONDecoding
import BSONEncoding
import SourceMaps

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
    public
    typealias Identity = FileIdentifier

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
    public
    var description:String
    {
        let hex:String = .init(UInt32.init(bitPattern: self.value), radix: 16)
        return "0x\(String.init(repeating: "0", count: 8 - hex.count))"
    }
}
