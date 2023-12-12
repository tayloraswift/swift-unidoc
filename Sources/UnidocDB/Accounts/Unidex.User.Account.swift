import GitHubAPI
import UnidocRecords

extension Unidex.User
{
    @frozen public
    enum Account:Sendable
    {
        case machine(Int32)
        case github(GitHub.User)
    }
}
extension Unidex.User.Account:Identifiable
{
    @inlinable public
    var id:Unidex.User.ID
    {
        switch self
        {
        case .machine(let user):    .machine(user)
        case .github(let user):     .github(user.id)
        }
    }
}
