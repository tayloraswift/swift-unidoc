import Media

@frozen public
enum ServerResponse:Equatable, Sendable
{
    case redirect(ServerRedirect, cookies:[Cookie] = [])
    case resource(ServerResource)
}
extension ServerResponse
{
    @inlinable public static
    func redirect(_ redirect:ServerRedirect, cookies:KeyValuePairs<String, String>) -> Self
    {
        .redirect(redirect, cookies: cookies.map(Cookie.init(name:value:)))
    }
}
extension ServerResponse
{
    @inlinable public
    var resource:ServerResource?
    {
        switch self
        {
        case .redirect:                 return nil
        case .resource(let resource):   return resource
        }
    }
}
