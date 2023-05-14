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
        self.init(rawValue.split(separator: " ").map(String.init(_:)))
    }
}
extension UnqualifiedPath:BSONDecodable, BSONEncodable
{
}
