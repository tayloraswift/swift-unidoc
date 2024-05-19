extension HTTP
{
    @frozen public
    enum Scheme
    {
        case http(port:Int = 80)
        case https(port:Int = 443)
    }
}
extension HTTP.Scheme
{
    @inlinable public static
    var http:Self { .http() }

    @inlinable public static
    var https:Self { .https() }
}
extension HTTP.Scheme
{
    @inlinable public
    var port:Int
    {
        switch self
        {
        case .http(port: let port):     port
        case .https(port: let port):    port
        }
    }
    @inlinable public
    var name:String
    {
        switch self
        {
        case .http:     "http"
        case .https:    "https"
        }
    }
}
