import JSON

extension Unidoc
{
    @frozen public
    enum LinkerAction:Int32, Equatable, Sendable
    {
        case uplinkInitial = 0
        case uplinkRefresh
        case unlink
        case delete
    }
}
extension Unidoc.LinkerAction:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        switch self
        {
        case .uplinkInitial:    "UPLINK_INITIAL"
        case .uplinkRefresh:    "UPLINK_REFRESH"
        case .unlink:           "UNLINK"
        case .delete:           "DELETE"
        }
    }
}
extension Unidoc.LinkerAction:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:String)
    {
        switch description
        {
        case "UPLINK_INITIAL":  self = .uplinkInitial
        case "UPLINK_REFRESH":  self = .uplinkRefresh
        case "UNLINK":          self = .unlink
        case "DELETE":          self = .delete
        default:                return nil
        }
    }
}
extension Unidoc.LinkerAction:JSONStringDecodable, JSONStringEncodable
{
}
