import HTTPServer
import UnidocQueries
import UnidocSelectors
import URI

extension ThinQuery.Output:ServerResponseFactory
{
    public
    func response(for _:URI) throws -> ServerResponse
    {
        if  LookupMode.self is Selector.Planes.Type
        {
            let inliner:Inliner = .init(principal: self.zone)
                inliner.masters.add(self.masters)

            let feed:Site.Guides.Feed = .init(inliner, masters: self.masters)

            return .resource(feed.rendered())
        }
        else if let redirect:URI = self.redirect
        {
            return .redirect(.permanent("\(redirect)"))
        }
        else
        {
            return .resource(.init(.none,
                content: .text("Record not found."),
                type: .text(.plain, charset: .utf8)))
        }
    }

    private
    var redirect:URI?
    {
        switch self.masters.first
        {
        case .article(let master)?:
            return .init(article: master, in: self.zone)

        case .culture(let master)?:
            return .init(culture: master, in: self.zone)

        case .decl(let master)?:
            return .init(decl: master, in: self.zone, disambiguate: self.masters.count == 1)

        case .file?, nil:
            return nil
        }
    }
}
