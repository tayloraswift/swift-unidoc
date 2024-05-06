import HTTP
import Media
import MongoDB
import UnidocRender
import UnidocDB
import UnidocQueries
import UnidocRecords
import URI

extension Unidoc
{
    @frozen public
    struct RedirectEndpoint<Predicate> where Predicate:VertexPredicate
    {
        public
        let query:RedirectQuery<Predicate>
        public
        var value:RedirectOutput?

        @inlinable public
        init(query:RedirectQuery<Predicate>)
        {
            self.query = query
            self.value = nil
        }
    }
}
extension Unidoc.RedirectEndpoint:Mongo.PipelineEndpoint, Mongo.SingleOutputEndpoint
{
    @inlinable public static
    var replica:Mongo.ReadPreference { .nearest }
}
extension Unidoc.RedirectEndpoint:HTTP.ServerEndpoint
{
    public consuming
    func response(as format:Unidoc.RenderFormat) throws -> HTTP.ServerResponse
    {
        guard
        let output:Unidoc.RedirectOutput = self.value
        else
        {
            return .notFound("Volume not found")
        }

        let redirect:URI? = switch output.matches.first
        {
        case .article(let vertex)?: Unidoc.DocsEndpoint[output.volume, vertex.route]
        case .culture(let vertex)?: Unidoc.DocsEndpoint[output.volume, vertex.route]
        //  This is one of the few situations where we intentionally issue redirects
        //  to a disambiguation page.
        case .decl(let vertex)?:    Unidoc.DocsEndpoint[output.volume,
            output.matches.count > 1 ? .bare(vertex.stem) : vertex.route]
        case .file?, nil:           nil
        case .product(let vertex)?: Unidoc.DocsEndpoint[output.volume, vertex.route]
        case .foreign(let vertex)?: Unidoc.DocsEndpoint[output.volume, vertex.route]
        case .landing?:             Unidoc.DocsEndpoint[output.volume]
        }

        if  let redirect:URI
        {
            return .redirect(.permanent("\(redirect)"))
        }
        else
        {
            let context:Unidoc.PeripheralPageContext = .init(canonical: nil,
                principal: output.volume,
                secondary: [],
                packages: [],
                tooltips: .init(),
                vertices: .init(secondary: output.matches))

            let display:Unidoc.DocsEndpoint.NotFoundPage = .init(context, sidebar: nil)
            //  We return 410 Gone instead of 404 Not Found so that search engines and
            //  research bots will stop crawling this URL. But the page appears the same
            //  to the user.
            return .gone(display.resource(format: format))
        }
    }
}
