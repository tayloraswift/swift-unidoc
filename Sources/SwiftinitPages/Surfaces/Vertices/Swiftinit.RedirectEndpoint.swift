import HTTP
import Media
import MongoDB
import SwiftinitRender
import UnidocDB
import UnidocQueries
import UnidocRecords
import URI

extension Swiftinit
{
    @frozen public
    struct RedirectEndpoint<Predicate>:Mongo.PipelineEndpoint, Mongo.SingleOutputEndpoint
        where Predicate:Unidoc.VertexPredicate
    {
        public
        let query:Unidoc.RedirectQuery<Predicate>
        public
        var value:Unidoc.RedirectOutput?

        @inlinable public
        init(query:Unidoc.RedirectQuery<Predicate>)
        {
            self.query = query
            self.value = nil
        }
    }
}
extension Swiftinit.RedirectEndpoint:HTTP.ServerEndpoint
{
    public consuming
    func response(as format:Swiftinit.RenderFormat) throws -> HTTP.ServerResponse
    {
        guard
        let output:Unidoc.RedirectOutput = self.value
        else
        {
            return .notFound("Volume not found")
        }

        let redirect:URI? = switch output.matches.first
        {
        case .article(let vertex)?: Swiftinit.Docs[output.volume, vertex.route]
        case .culture(let vertex)?: Swiftinit.Docs[output.volume, vertex.route]
        //  This is one of the few situations where we intentionally issue redirects
        //  to a disambiguation page.
        case .decl(let vertex)?:    Swiftinit.Docs[output.volume,
            output.matches.count > 1 ? .bare(vertex.stem) : vertex.route]
        case .file?, nil:           nil
        case .product(let vertex)?: Swiftinit.Docs[output.volume, vertex.route]
        case .foreign(let vertex)?: Swiftinit.Docs[output.volume, vertex.route]
        case .global?:              Swiftinit.Docs[output.volume]
        }

        if  let redirect:URI
        {
            return .redirect(.permanent("\(redirect)"))
        }
        else
        {
            let context:IdentifiablePageContext<Swiftinit.SecondaryOnly> = .init(cache: .init(
                    vertices: .init(secondary: output.matches),
                    volumes: .init(principal: output.volume)),
                repo: nil)

            let display:Swiftinit.Docs.NotFoundPage = .init(context, sidebar: nil)
            //  We return 410 Gone instead of 404 Not Found so that search engines and
            //  research bots will stop crawling this URL. But the page appears the same
            //  to the user.
            return .gone(display.resource(format: format))
        }
    }
}
