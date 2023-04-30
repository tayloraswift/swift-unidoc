import BSONDecoding
import BSONEncoding
import SourceMaps

@frozen public
struct FileAddress
{
    public
    let value:UInt32

    @inlinable public
    init(value:UInt32)
    {
        self.value = value
    }
}
extension FileAddress:SymbolAddress
{
    public
    typealias Identity = FileIdentifier

    @inlinable public
    init(exactly uint32:UInt32)
    {
        self.init(value: uint32)
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
        let hex:String = .init(self.value, radix: 16)
        return "0x\(String.init(repeating: "0", count: 8 - hex.count))"
    }
}
