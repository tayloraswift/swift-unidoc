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
            Crawl-delay: 20


            User-agent: semrushbot
            Crawl-delay: 20


            User-agent: ahrefsbot
            Crawl-delay: 20


            User-agent: blexbot
            Crawl-delay: 20


            User-agent: seo spider
            Crawl-delay: 20


            User-agent: MJ12bot
            Crawl-delay: 20


            User-agent: Bytespider
            Crawl-delay: 10


            User-agent: *
            Disallow: /admin/
            Disallow: /auth/
            Disallow: /hist/
            Disallow: /reference/
            Disallow: /telescope/

            """)
    }
}
