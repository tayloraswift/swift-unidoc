import HTTP
import Media
import UnidocQueries
import UnidocRecords
import URI

extension ThinQuery.Output:ServerResponseFactory
{
    public
    func response(as _:AcceptType?) throws -> ServerResponse
    {
        if  LookupPredicate.self is Volume.Range.Type
        {
            let inliner:Inliner = .init(principal: self.names, repo: nil)
                inliner.vertices.add(self.masters)

            let feed:Site.Guides.Feed = .init(inliner, masters: self.masters)

            return .ok(feed.resource())
        }
        else if let redirect:URI = self.redirect
        {
            return .redirect(.permanent("\(redirect)"))
        }
        else
        {
            let inliner:Inliner = .init(principal: self.names, repo: nil)
                inliner.vertices.add(self.masters)

            let display:Site.Docs.NotFound = .init(inliner, nouns: nil)
            //  We return 410 Gone instead of 404 Not Found so that search engines and
            //  research bots will stop crawling this URL. But the page appears the same
            //  to the user.
            return .gone(display.resource())
        }
    }

    private
    var redirect:URI?
    {
        switch self.masters.first
        {
        case .article(let master)?: return Site.Docs[self.names, master.shoot]
        case .culture(let master)?: return Site.Docs[self.names, master.shoot]
        //  This is one of the few situations where we intentionally issue redirects
        //  to a disambiguation page.
        case .decl(let master)?:    return Site.Docs[self.names,
            self.masters.count > 1 ? .init(stem: master.stem) : master.shoot]
        case .file?, nil:           return nil
        case .global?:              return Site.Docs[self.names]
        }
    }
}
