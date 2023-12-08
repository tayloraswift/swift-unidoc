import HTTPServer
import IP
import Media
import MD5
import Multiparts
import NIOHPACK
import NIOHTTP1
import UnidocAutomation
import UnidocDB
import UnidocPages
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
    init?(get metadata:consuming Metadata, tag:MD5?)
    {
        guard
        let uri:URI = .init((copy metadata).path)
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
                endpoint: .interactive(Swiftinit.PipelineEndpoint<RecentActivityQuery>.init(
                    output: parameters.explain ? nil : .text(.html),
                    query: .init(limit: 16),
                    tag: tag)),
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
            case Site.Admin.root:
                endpoint = .interactive(Swiftinit.AdminDashboardEndpoint.status)

            case Site.Login.root:
                endpoint = .interactive(Swiftinit.BounceEndpoint.init())

            case "robots.txt":
                endpoint = .interactive(Swiftinit.RobotsEndpoint.init())

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
        case Site.Admin.root:
            endpoint = .get(admin: trunk, path, tag: tag)

        case Site.Asset.root:
            endpoint = .get(asset: trunk, tag: tag)

        case "auth":
            endpoint = .get(auth: trunk,
                with: .init(uri.query?.parameters))

        case Site.Blog.root:
            endpoint = .get(articles: trunk,
                with: .init(uri.query?.parameters),
                tag: tag)

        case Site.Docs.root:
            endpoint = .get(docs: trunk, path,
                with: .init(uri.query?.parameters),
                tag: tag)

        case "lunr":
            endpoint = .get(lunr: trunk,
                with: .init(uri.query?.parameters),
                tag: tag)

        //  Deprecated route.
        case "sitemaps":
            endpoint = .redirect("/\(Site.Docs.root)/\(trunk.prefix { $0 != "." })/all-symbols")

        case Site.Stats.root:
            endpoint = .get(stats: trunk, path,
                with: .init(uri.query?.parameters),
                tag: tag)

        case Site.Tags.root:
            endpoint = .get(tags: trunk,
                with: .init(uri.query?.parameters),
                tag: tag)

        case UnidocAPI.root:
            endpoint = .get(api: trunk, path,
                with: .init(uri.query?.parameters),
                tag: tag)

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
    init?(post metadata:consuming Metadata, body:consuming [UInt8], type:ContentType)
    {
        guard
        let uri:URI = .init((copy metadata).path)
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
        case Site.Admin.root:
            endpoint = try? .post(admin: trunk, path, body: body, type: type)

        case UnidocAPI.root:
            endpoint = try? .post(api: trunk, body: body, type: type)

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
