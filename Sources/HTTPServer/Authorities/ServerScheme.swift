@frozen public
enum ServerScheme
{
    case https(port:Int = 443)
    case http(port:Int = 80)
}
extension ServerScheme
{
    @inlinable public static
    var https:Self { .https() }

    @inlinable public static
    var http:Self { .http() }
}
extension ServerScheme
{
    @inlinable public
    var port:Int
    {
        switch self
        {
        case .http(port: let port):     return port
        case .https(port: let port):    return port
        }
    }
    @inlinable public
    var name:String
    {
        switch self
        {
        case .http:             return "http"
        case .https:            return "https"
        }
    }
}
