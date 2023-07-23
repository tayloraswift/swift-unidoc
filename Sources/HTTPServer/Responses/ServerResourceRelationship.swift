/// https://developer.mozilla.org/en-US/docs/Web/HTML/Attributes/rel
@frozen public
enum ServerResourceRelationship:String, Equatable, Hashable, Sendable
{
    case author
    case alternate
    case canonical
    case dnsPrefetch = "dns-prefetch"
    case help
    case icon
    case license
    case manifest
    case me
    case modulepreload
    case next
    case pingback
    case preconnect
    case prefetch
    case preload
    case prerender
    case prev
    case search
    case stylesheet
}
extension ServerResourceRelationship:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        self.rawValue
    }
}
