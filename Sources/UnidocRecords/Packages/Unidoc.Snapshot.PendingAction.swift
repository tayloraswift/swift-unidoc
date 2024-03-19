import BSON

extension Unidoc.Snapshot
{
    @frozen public
    enum PendingAction:Int32, Equatable, Sendable
    {
        case uplinkInitial = 0
        case uplinkRefresh
        case unlink
        case delete
    }
}
extension Unidoc.Snapshot.PendingAction:BSONDecodable, BSONEncodable
{
}
extension Unidoc.Snapshot.PendingAction:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        switch self
        {
        case .uplinkInitial:    "uplink (initial)"
        case .uplinkRefresh:    "uplink (refresh)"
        case .unlink:           "unlink"
        case .delete:           "delete"
        }
    }
}
