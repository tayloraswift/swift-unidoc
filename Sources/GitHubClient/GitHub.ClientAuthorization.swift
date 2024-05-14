import Base64
import GitHubAPI

extension GitHub
{
    @frozen public
    enum ClientAuthorization
    {
        case basic(GitHub.OAuth)
        case token(String)
    }
}
extension GitHub.ClientAuthorization
{
    @inlinable
    var header:String
    {
        switch self
        {
        case .basic(let oauth):
            let unencoded:String = "\(oauth.client):\(oauth.secret)"
            return "Basic \(Base64.encode(unencoded.utf8))"

        case .token(let token):
            return "Bearer \(token)"
        }
    }
}
