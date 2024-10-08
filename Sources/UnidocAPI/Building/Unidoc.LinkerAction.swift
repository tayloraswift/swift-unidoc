import JSON

extension Unidoc
{
    @frozen public
    enum LinkerAction:Int32, Equatable, Sendable
    {
        case uplink = 1
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
        case .uplink:   "UPLINK"
        case .unlink:   "UNLINK"
        case .delete:   "DELETE"
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
        case "UPLINK":  self = .uplink
        case "UNLINK":  self = .unlink
        case "DELETE":  self = .delete
        default:        return nil
        }
    }
}
extension Unidoc.LinkerAction:JSONStringDecodable, JSONStringEncodable
{
}
