import BSON

extension Unidoc
{
    @frozen public
    enum GraphType:Int32, Sendable
    {
        /// Uncompressed BSON.
        case bson = 0
        /// Zlib-compressed BSON.
        case bson_zz = 1
    }
}
extension Unidoc.GraphType:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        switch self
        {
        case .bson:     "bson"
        case .bson_zz:  "bson.zz"
        }
    }
}
extension Unidoc.GraphType:BSONDecodable, BSONEncodable
{
}
