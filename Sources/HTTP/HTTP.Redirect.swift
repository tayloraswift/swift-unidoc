@available(*, deprecated, renamed: "HTTP.Redirect")
public
typealias ServerRedirect = HTTP.Redirect

extension HTTP
{
    @frozen public
    enum Redirect:Equatable, Sendable
    {
        case permanent(String)
        case temporary(String)
    }
}
extension HTTP.Redirect
{
    @inlinable public
    var location:String
    {
        switch self
        {
        case .permanent(let location):  return location
        case .temporary(let location):  return location
        }
    }
}
