import Media

@frozen public
enum ServerResponse:Equatable, Sendable
{
    case error      (ServerResource)
    case forbidden  (ServerResource)
    case ok         (ServerResource)
    case multiple   (ServerResource)
    case notFound   (ServerResource)

    case redirect   (ServerRedirect, cookies:[Cookie] = [])
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
    var size:Int
    {
        switch self
        {
        case .redirect:                 return 0
        case .error     (let resource): return resource.content.size
        case .forbidden (let resource): return resource.content.size
        case .ok        (let resource): return resource.content.size
        case .multiple  (let resource): return resource.content.size
        case .notFound  (let resource): return resource.content.size
        }
    }
}
