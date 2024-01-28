import HTTPServer
import IP
import MD5
import Media
import Multiparts
import NIOHPACK
import NIOHTTP1
import SwiftinitPages
import UnidocDB
import UnidocProfiling
import UnidocQueries
import URI

extension Swiftinit
{
    struct IntegralRequest:Sendable
    {
        let endpoint:AnyEndpoint
        let metadata:Metadata

        init(endpoint:AnyEndpoint, metadata:Metadata)
        {
            self.endpoint = endpoint
            self.metadata = metadata
        }
    }
}
extension Swiftinit.IntegralRequest:HTTP.ServerIntegralRequest
{
    init?(get path:String,
        headers:borrowing HTTPHeaders,
        address:IP.V6,
        service:IP.Service?)
    {
        let metadata:Metadata = .init(
            headers: headers,
            address: address,
            service: service,
            path: path)

        //  Only search engines are allowed to use HTTP/1.1. Bingbot never uses
        //  HTTP/1.1, but we allow it anyway.
        switch metadata.annotation
        {
        //  There is no legitimate reason for a doll, even a barbie, to use HTTP/1.1.
        //  Such a doll is almost certainly a malicious bot that somehow passed the
        //  barbie filter.
        case .barbie(_):            return nil
        case .bratz:                return nil
        case .robot(.ahrefsbot):    return nil
        //  Crawls way too fast.
        case .robot(.amazonbot):    return nil
        case .robot(.baiduspider):  break
        case .robot(.bingbot):      break
        case .robot(.bytespider):   return nil
        case .robot(.cloudfront):   break
        case .robot(.duckduckbot):  break
        case .robot(.google):       break
        case .robot(.googlebot):    break
        case .robot(.quant):        break
        case .robot(.naver):        break
        case .robot(.petal):        break
        case .robot(.seznam):       break
        case .robot(.yandexbot):    break
        case .robot(.unknown):      break
        case .robot(.other):        return nil
        case .robot(.tool):         return nil
        }

        self.init(get: metadata, tag: .init(header: headers["if-none-match"]))
    }

    init?(get path:String,
        headers:borrowing HPACKHeaders,
        address:IP.V6,
        service:IP.Service?)
    {
        let metadata:Metadata = .init(
            headers: headers,
            address: address,
            service: service,
            path: path)

        if  path != "/robots.txt"
        {
            switch metadata.annotation
            {
            case .robot(.bytespider):   return nil
            default:                    break
            }
        }

        self.init(get: metadata, tag: .init(header: headers["if-none-match"]))
    }

    init?(post path:String,
        headers:borrowing HPACKHeaders,
        address:IP.V6,
        service:IP.Service?,
        body:consuming [UInt8])
    {
        let metadata:Metadata = .init(
            headers: headers,
            address: address,
            service: service,
            path: path)

        guard
        let type:String = headers["content-type"].first,
        let type:ContentType = .init(type)
        else
        {
            return nil
        }

        self.init(post: metadata, body: body, type: type)
    }
}
extension Swiftinit.IntegralRequest
{
    private
    init?(get metadata:Metadata, tag:MD5?)
    {
        guard
        let uri:URI = .init(metadata.path)
        else
        {
            return nil
        }

        var path:ArraySlice<String> = uri.path.normalized(lowercase: true)[...]

        guard
        let root:String = path.popFirst()
        else
        {
            let parameters:Swiftinit.PipelineParameters = .init(uri.query?.parameters)

            self.init(
                endpoint: .explainable(Swiftinit.HomeEndpoint.init(query: .init(limit: 16)),
                    parameters: parameters),
                metadata: metadata)

            return
        }

        guard
        let trunk:String = path.popFirst()
        else
        {
            let endpoint:Swiftinit.AnyEndpoint

            switch root
            {
            case Swiftinit.Root.admin.id:
                endpoint = .interactive(Swiftinit.DashboardEndpoint.master)

            case Swiftinit.Root.login.id:
                endpoint = .interactive(Swiftinit.BounceEndpoint.init())

            case "robots.txt":
                let parameters:Swiftinit.PipelineParameters = .init(uri.query?.parameters,
                    tag: tag)

                endpoint = .explainable(Swiftinit.TextEndpoint.init(query: .init(
                        tag: parameters.tag,
                        id: .robots_txt)),
                    parameters: parameters)

            case "sitemap.xml":
                endpoint = .interactive(Swiftinit.SitemapIndexEndpoint.init(tag: tag))

            case _:
                return nil
            }

            self.init(endpoint: endpoint, metadata: metadata)
            return
        }

        let endpoint:Swiftinit.AnyEndpoint?

        switch root
        {
        case Swiftinit.Root.api.id:
            endpoint = .get(api: trunk, path,
                with: .init(uri.query?.parameters, tag: tag))

        case Swiftinit.Root.admin.id:
            endpoint = .get(admin: trunk, path, tag: tag)

        case Swiftinit.Root.asset.id:
            endpoint = .get(asset: trunk, tag: tag)

        case "auth":
            endpoint = .get(auth: trunk,
                with: .init(uri.query?.parameters))

        case Swiftinit.Root.blog.id:
            endpoint = .get(articles: trunk,
                with: .init(uri.query?.parameters, tag: tag))

        case Swiftinit.Root.docs.id, Swiftinit.Root.docc.id, Swiftinit.Root.hist.id:
            endpoint = .get(docs: trunk, path,
                with: .init(uri.query?.parameters, tag: tag))

        case Swiftinit.Root.lunr.id:
            endpoint = .get(lunr: trunk,
                with: .init(uri.query?.parameters, tag: tag))

        case Swiftinit.Root.plugin.id:
            endpoint = .interactive(Swiftinit.DashboardEndpoint.plugin(trunk))

        case Swiftinit.Root.ptcl.id:
            endpoint = .get(ptcl: trunk, path,
                with: .init(uri.query?.parameters, tag: tag))

        case Swiftinit.Root.realm.id:
            endpoint = .get(realm: trunk,
                with: .init(uri.query?.parameters, tag: tag))

        //  Deprecated route.
        case "sitemaps":
            endpoint = .redirect("""
                \(Swiftinit.Root.docs)/\(trunk.prefix { $0 != "." })/all-symbols
                """)

        case Swiftinit.Root.stats.id:
            endpoint = .get(stats: trunk, path,
                with: .init(uri.query?.parameters, tag: tag))

        case Swiftinit.Root.tags.id:
            endpoint = .get(tags: trunk,
                with: .init(uri.query?.parameters,
                    user: metadata.cookies.session?.user,
                    tag: tag))

        case Swiftinit.Root.telescope.id:
            endpoint = .get(telescope: trunk,
                with: .init(uri.query?.parameters, tag: tag))

        case "reference":
            endpoint = .get(legacy: trunk, path,
                with: .init(uri.query?.parameters))

        case "learn":
            endpoint = .get(legacy: trunk, path,
                with: .init(uri.query?.parameters))

        case _:
            return nil
        }

        if  let endpoint:Swiftinit.AnyEndpoint
        {
            self.init(endpoint: endpoint, metadata: metadata)
        }
        else
        {
            return nil
        }
    }

    private
    init?(post metadata:Metadata, body:consuming [UInt8], type:ContentType)
    {
        guard
        let uri:URI = .init(metadata.path)
        else
        {
            return nil
        }

        var path:ArraySlice<String> = uri.path.normalized(lowercase: true)[...]

        guard
        let root:String = path.popFirst(),
        let trunk:String = path.popFirst()
        else
        {
            return nil
        }

        let endpoint:Swiftinit.AnyEndpoint?

        switch root
        {
        case Swiftinit.Root.api.id:
            endpoint = try? .post(api: trunk, body: body, type: type)

        case Swiftinit.Root.admin.id:
            endpoint = try? .post(admin: trunk, path, body: body, type: type)

        case _:
            return nil
        }

        if  let endpoint:Swiftinit.AnyEndpoint
        {
            self.init(endpoint: endpoint, metadata: metadata)
        }
        else
        {
            return nil
        }
    }
}
