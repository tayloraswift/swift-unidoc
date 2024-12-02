extension HTTP
{
    @frozen public
    enum Scheme:Equatable, Sendable
    {
        case http
        case https
    }
}
extension HTTP.Scheme
{
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
extension HTTP.Scheme:CustomStringConvertible
{
    @inlinable public
    var description:String { self.name }
}
