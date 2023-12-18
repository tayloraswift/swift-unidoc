import HTTP
import Media
import SwiftinitRender
import UnidocQueries
import UnidocRecords
import URI

extension Unidoc.RedirectOutput:HTTP.ServerResponseFactory
{
    public borrowing
    func response(as format:Swiftinit.RenderFormat) throws -> HTTP.ServerResponse
    {
        if  let redirect:URI = self.redirect
        {
            return .redirect(.permanent("\(redirect)"))
        }
        else
        {
            let context:IdentifiablePageContext<Never?> = .init(principal: self.volume,
                repo: nil)

            context.vertices.add(self.matches)

            let display:Swiftinit.Docs.NotFoundPage = .init(context, sidebar: nil)
            //  We return 410 Gone instead of 404 Not Found so that search engines and
            //  research bots will stop crawling this URL. But the page appears the same
            //  to the user.
            return .gone(display.resource(format: format))
        }
    }

    private
    var redirect:URI?
    {
        switch self.matches.first
        {
        case .article(let vertex)?: Swiftinit.Docs[self.volume, vertex.shoot]
        case .culture(let vertex)?: Swiftinit.Docs[self.volume, vertex.shoot]
        //  This is one of the few situations where we intentionally issue redirects
        //  to a disambiguation page.
        case .decl(let vertex)?:    Swiftinit.Docs[self.volume,
            self.matches.count > 1 ? .init(stem: vertex.stem) : vertex.shoot]
        case .file?, nil:           nil
        case .product(let vertex)?: Swiftinit.Docs[self.volume, vertex.shoot]
        case .foreign(let vertex)?: Swiftinit.Docs[self.volume, vertex.shoot]
        case .global?:              Swiftinit.Docs[self.volume]
        }
    }
}
