import GitHubAPI
import UnidocRecords

extension Unidoc.User
{
    @frozen public
    enum Account:Equatable, Sendable
    {
        case machine(Int32)
        case github(GitHub.User)
    }
}
extension Unidoc.User.Account:Identifiable
{
    @inlinable public
    var id:Unidoc.User.ID
    {
        switch self
        {
        case .machine(let user):    .machine(user)
        case .github(let user):     .github(user.id)
        }
    }
}
