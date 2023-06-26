import BSONDecoding
import BSONEncoding
import Sources

extension SourceLocation<Int32>:BSONDecodable, BSONEncodable, BSONWeakEncodable
{
}
