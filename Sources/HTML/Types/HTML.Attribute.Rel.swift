extension HTML.Attribute
{
    /// https://developer.mozilla.org/en-US/docs/Web/HTML/Attributes/rel
    @frozen public
    enum Rel:String, Equatable, Hashable, Sendable
    {
        case alternate
        case author
        case bookmark
        case canonical
        case dnsPrefetch = "dns-prefetch"
        case external
        case help
        case icon
        case license
        case manifest
        case me
        case modulepreload
        case next
        case nofollow
        case noopener
        case noreferrer
        case opener
        case pingback
        case preconnect
        case prefetch
        case preload
        case prerender
        case prev
        case search
        case stylesheet
        case tag

        //  Unofficial extensions.
        //  See: https://github.com/whatwg/html/issues/5367.
        case google_sponsored = "sponsored"
        case google_ugc = "ugc"
    }
}
extension HTML.Attribute.Rel:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        self.rawValue
    }
}
