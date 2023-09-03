import BSONDecoding
import BSONEncoding

extension User
{
    @frozen public
    enum Role:String, BSONDecodable, BSONEncodable
    {
        case admin
        case normal
    }
}
