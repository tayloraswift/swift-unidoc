import BSON

extension Unidoc
{
    @frozen public
    enum GroupLayer:Int32, Sendable
    {
        case protocols = 1
    }
}
extension Unidoc.GroupLayer:BSONDecodable, BSONEncodable
{
}
