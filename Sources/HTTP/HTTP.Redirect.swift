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
        case see(other:String)
    }
}
extension HTTP.Redirect
{
    @inlinable public
    var location:String
    {
        switch self
        {
        case .permanent(let location):  location
        case .temporary(let location):  location
        case .see(let location):        location
        }
    }
}
