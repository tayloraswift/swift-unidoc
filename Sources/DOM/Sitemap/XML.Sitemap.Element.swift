extension XML.Sitemap
{
    @frozen public
    enum Element:String, Equatable, Hashable, Sendable
    {
        case changefreq
        case lastmod
        case loc
        case priority
        case sitemap
        case sitemapindex
        case url
        case urlset
    }
}
