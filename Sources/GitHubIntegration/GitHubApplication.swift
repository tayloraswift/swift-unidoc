import HTTPClient
import JSON
import NIOCore
import NIOHPACK

@frozen public
struct GitHubApplication:Identifiable, Equatable, Hashable, Sendable
{
    public
    let secret:String
    public
    let id:String

    @inlinable public
    init(_ id:String, secret:String = "3a892428d6381dbcfdafab55ad2fbec6d4847430")
    {
        self.id = id
        self.secret = secret
    }
}
