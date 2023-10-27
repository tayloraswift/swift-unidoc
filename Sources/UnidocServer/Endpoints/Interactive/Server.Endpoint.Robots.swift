import HTTP
import UnidocPages

extension Server.Endpoint
{
    /// Serves the `robots.txt` file.
    struct Robots:Sendable
    {
        init()
        {
        }
    }
}
extension Server.Endpoint.Robots:PublicEndpoint
{
    func load(from server:Server) -> ServerResponse?
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

            """)
    }
}
