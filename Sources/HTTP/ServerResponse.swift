import Media

@frozen public
enum ServerResponse:Equatable, Sendable
{
    /// 200 OK.
    case ok             (ServerResource)
    /// 300 Multiple Choices.
    case multiple       (ServerResource)
    /// 400 Bad Request.
    case badRequest     (ServerResource)
    /// 401 Unauthorized.
    case unauthorized   (ServerResource)
    /// 403 Forbidden.
    case forbidden      (ServerResource)
    /// 404 Not Found.
    case notFound       (ServerResource)
    /// 409 Conflict.
    case conflict       (ServerResource)
    /// 410 Gone.
    case gone           (ServerResource)
    /// 500 Internal Server Error.
    case error          (ServerResource)

    case redirect       (ServerRedirect, cookies:[Cookie] = [])
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
        case .redirect:                     return 0
        case .ok            (let resource): return resource.content.size
        case .multiple      (let resource): return resource.content.size
        case .badRequest    (let resource): return resource.content.size
        case .unauthorized  (let resource): return resource.content.size
        case .forbidden     (let resource): return resource.content.size
        case .notFound      (let resource): return resource.content.size
        case .gone          (let resource): return resource.content.size
        case .conflict      (let resource): return resource.content.size
        case .error         (let resource): return resource.content.size
        }
    }
}
