import HTTP
import UnidocQueries
import UnidocRender
import URI

extension Unidoc.RedirectOutput
{
    public
    func response(as format:Unidoc.RenderFormat) -> HTTP.ServerResponse
    {
        let redirect:URI? = switch self.matches.first
        {
        case .article(let vertex)?: Unidoc.DocsEndpoint[self.volume, vertex.route]
        case .culture(let vertex)?: Unidoc.DocsEndpoint[self.volume, vertex.route]
        //  This is one of the few situations where we intentionally issue redirects
        //  to a disambiguation page.
        case .decl(let vertex)?:    Unidoc.DocsEndpoint[self.volume,
            self.matches.count > 1 ? .bare(vertex.stem) : vertex.route]
        case .file?, nil:           nil
        case .product(let vertex)?: Unidoc.DocsEndpoint[self.volume, vertex.route]
        case .foreign(let vertex)?: Unidoc.DocsEndpoint[self.volume, vertex.route]
        case .landing?:             Unidoc.DocsEndpoint[self.volume]
        }

        if  let redirect:URI
        {
            return .redirect(.permanent("\(redirect)"))
        }
        else
        {
            let context:Unidoc.PeripheralPageContext = .init(canonical: nil,
                principal: self.volume,
                secondary: [],
                packages: [],
                vertices: .init(secondary: self.matches))

            let display:Unidoc.DocsEndpoint.NotFoundPage = .init(context, sidebar: .module(
                volume: context.volume,
                tree: nil))
            //  We return 410 Gone instead of 404 Not Found so that search engines and
            //  research bots will stop crawling this URL. But the page appears the same
            //  to the user.
            return .gone(display.resource(format: format))
        }
    }
}
