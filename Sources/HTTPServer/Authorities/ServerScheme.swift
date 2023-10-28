@frozen public
enum ServerScheme
{
    case https(port:Int = 443)
}
extension ServerScheme
{
    @inlinable public static
    var https:Self { .https() }
}
extension ServerScheme
{
    @inlinable public
    var port:Int
    {
        switch self
        {
        case .https(port: let port): port
        }
    }
    @inlinable public
    var name:String
    {
        switch self
        {
        case .https: "https"
        }
    }
}
