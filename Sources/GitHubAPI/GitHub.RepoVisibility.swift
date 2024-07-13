import JSON

extension GitHub
{
    @frozen public
    enum RepoVisibility:Equatable, Comparable, Sendable
    {
        case `private`
        case `internal`
        case `public`
    }
}
extension GitHub.RepoVisibility:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        switch self
        {
        case .private:  "private"
        case .internal: "internal"
        case .public:   "public"
        }
    }
}
extension GitHub.RepoVisibility:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:String)
    {
        //  Note: the GraphQL API returns the visibility in all caps, for some reason.
        switch description
        {
        case "PRIVATE":  self = .private
        case "private":  self = .private

        case "INTERNAL": self = .internal
        case "internal": self = .internal

        case "PUBLIC":   self = .public
        case "public":   self = .public

        default:         return nil
        }
    }
}
extension GitHub.RepoVisibility:JSONStringDecodable
{
}
