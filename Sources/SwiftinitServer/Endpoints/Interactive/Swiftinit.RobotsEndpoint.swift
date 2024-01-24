import HTTP

extension Swiftinit
{
    /// Serves the `robots.txt` file.
    struct RobotsEndpoint:Sendable
    {
        init()
        {
        }
    }
}
extension Swiftinit.RobotsEndpoint:PublicEndpoint
{
    func load(from server:borrowing Swiftinit.Server,
        as _:Swiftinit.RenderFormat) -> HTTP.ServerResponse?
    {
        .ok("""
            User-agent: mauibot
            Crawl-delay: 60


            User-agent: semrushbot
            Crawl-delay: 60


            User-agent: ahrefsbot
            Crawl-delay: 60


            User-agent: blexbot
            Crawl-delay: 60


            User-agent: seo spider
            Crawl-delay: 60


            User-agent: MJ12bot
            Crawl-delay: 60


            User-agent: Bytespider
            Crawl-delay: 60


            User-agent: *
            Disallow: /admin/
            Disallow: /auth/
            Disallow: /docc/
            Disallow: /hist/
            Disallow: /pdct/
            Disallow: /plugin/
            Disallow: /ptcl/
            Disallow: /reference/
            Disallow: /telescope/
            Disallow: /user/
            Disallow: /docs/swift-unidoc/
            Allow: /docs/swift-unidoc/guides/

            Sitemap: https://swiftinit.org/sitemap.xml

            """)
    }
}
