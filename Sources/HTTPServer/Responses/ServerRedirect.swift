@frozen public
enum ServerRedirect:Equatable, Sendable
{
    case permanent(String)
    case temporary(String)
}
extension ServerRedirect
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
