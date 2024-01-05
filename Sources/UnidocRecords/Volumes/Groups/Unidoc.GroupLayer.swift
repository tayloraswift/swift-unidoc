import BSON

extension Unidoc
{
    @frozen public
    enum GroupLayer:Int32, Sendable
    {
        case curations = 1
        case protocols = 2
    }
}
extension Unidoc.GroupLayer:BSONDecodable, BSONEncodable
{
}
