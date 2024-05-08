import JSON

extension GitHub.Ref
{
    @frozen public
    enum Prefix:Equatable, Sendable
    {
        case tags
        case heads
        case remotes
    }
}
extension GitHub.Ref.Prefix:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        switch self
        {
        case .tags:     "refs/tags/"
        case .heads:    "refs/heads/"
        case .remotes:  "refs/remotes/"
        }
    }
}
extension GitHub.Ref.Prefix:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:String)
    {
        switch description
        {
        case "refs/tags/":      self = .tags
        case "refs/heads/":     self = .heads
        case "refs/remotes/":   self = .remotes
        default:                return nil
        }
    }
}
extension GitHub.Ref.Prefix:JSONStringEncodable, JSONStringDecodable
{
}
