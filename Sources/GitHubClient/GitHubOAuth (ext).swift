import Base64
import GitHubAPI

extension GitHubOAuth
{
    /// Returns an HTTP authorization header value, encoded in Base64.
    @inlinable internal
    var authorization:String
    {
        let unencoded:String = "\(self.client):\(self.secret)"
        return "\(Base64.encode(unencoded.utf8))"
    }
}
