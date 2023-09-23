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
            return .notFound(.init(
                content: .string("Volume not found."),
                type: .text(.plain, charset: .utf8)))
        }
    }

    private
    var redirect:URI?
    {
        switch self.masters.first
        {
        case .article(let master)?: return Site.Docs[self.names, master.shoot]
        case .culture(let master)?: return Site.Docs[self.names, master.shoot]
        case .decl(let master)?:    return Site.Docs[self.names,
            self.masters.count > 1 ? .init(stem: master.stem) : master.shoot]
        case .file?, nil:           return nil
        case .meta?:                return Site.Docs[self.names]
        }
    }
}
