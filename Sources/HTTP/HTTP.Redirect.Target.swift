extension HTTP.Redirect
{
    @frozen public
    enum Target:Equatable, Sendable
    {
        /// Technically, these are absolute URIs, just not absolute URLs in the SEO sense.
        case domestic(String)
        case external(String)
    }
}
