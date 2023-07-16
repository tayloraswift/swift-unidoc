import BSONDecoding
import BSONEncoding
import LexicalPaths

extension UnqualifiedPath:RawRepresentable
{
    @inlinable public
    var rawValue:String
    {
        self.joined(separator: " ")
    }
    @inlinable public
    init?(rawValue:String)
    {
        self.init(splitting: rawValue[...]) { $0 == " " }
    }
}
extension UnqualifiedPath:BSONDecodable, BSONEncodable
{
}
