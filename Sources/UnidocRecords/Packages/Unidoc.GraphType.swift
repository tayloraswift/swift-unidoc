import BSON

extension Unidoc
{
    /// This currently only has one inhabitant, but eventually we should start compressing
    /// the symbol graphs.
    @frozen public
    enum GraphType:Int32, Sendable
    {
        /// Uncompressed BSON.
        case bson = 0
    }
}
extension Unidoc.GraphType:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        switch self
        {
        case .bson: "bson"
        }
    }
}
extension Unidoc.GraphType:BSONDecodable, BSONEncodable
{
}
