import HTTPServer
import Media
import MD5
import Multiparts
import NIOCore
import NIOHTTP1
import UnidocDB
import UnidocPages
import UnidocProfiling
import UnidocQueries
import URI

extension Server
{
    struct Operation:Sendable
    {
        let endpoint:Endpoint

        let cookies:Cookies
        let profile:ServerProfile.Sample

        init(endpoint:Endpoint, cookies:Cookies, profile:ServerProfile.Sample = .init())
        {
            self.endpoint = endpoint
            self.cookies = cookies
            self.profile = profile
        }
    }
}
extension Server.Operation:HTTPServerOperation
{
    init?(get unnormalized:String,
        address ip:SocketAddress?,
        headers:HTTPHeaders)
    {
        guard let uri:URI = .init(unnormalized)
        else
        {
            return nil
        }

        let cookies:Server.Cookies = .init(headers[canonicalForm: "cookie"])
        /// A native SwiftNIO ``IPv4Address`` is reference counted and resilient, and we
        /// would rather pass around an inline value type.
        let address:IP.Address?
        switch ip
        {
        case .v4(let ip)?:
            let bytes:UInt32 = .init(bigEndian: ip.address.sin_addr.s_addr)
            let value:IP.V4 = .init(
                .init((bytes >> 24) & 0xFF),
                .init((bytes >> 16) & 0xFF),
                .init((bytes >>  8) & 0xFF),
                .init( bytes        & 0xFF))

            address = .v4(value)

        case let ip?:
            address = .v6(ip.description)

        case _:
            address = nil
        }

        let profile:ServerProfile.Sample = .init(ip: address,
            language: headers["accept-language"].first,
            referer: headers["referer"].first,
            agent: headers["user-agent"].first,
            uri: unnormalized)

        let tag:MD5? = headers.ifNoneMatch.first.flatMap(MD5.init(_:))

        var path:ArraySlice<String> = uri.path.normalized(lowercase: true)[...]

        guard
        let root:String = path.popFirst()
        else
        {
            //  Hilariously, we don’t have a home page yet. So we just redirect to the docs
            //  for the standard library.
            let get:Server.Endpoint = .interactive(Server.Endpoint.Pipeline<WideQuery>.init(
                output: .text(.html),
                query: .init(
                    volume: .init(package: .swift, version: nil),
                    lookup: .init(stem: [])),
                tag: tag))

            self.init(endpoint: get, cookies: cookies, profile: profile)
            return
        }

        guard
        let trunk:String = path.popFirst()
        else
        {
            let endpoint:Server.Endpoint

            switch root
            {
            case Site.Admin.root:
                endpoint = .interactive(Server.Endpoint.AdminDashboard.status)

            case Site.Login.root:
                endpoint = .interactive(Server.Endpoint.Bounce.init())

            case "robots.txt":
                endpoint = .static(.init(.robots_txt, tag: tag))

            case _:
                return nil
            }

            self.init(endpoint: endpoint, cookies: cookies, profile: profile)
            return
        }

        let endpoint:Server.Endpoint?

        switch root
        {
        case Site.Admin.root:
            endpoint = .get(admin: trunk, path, tag: tag)

        case Site.API.root:
            endpoint = .get(api: trunk, path,
                with: .init(uri.query?.parameters),
                tag: tag)

        case Site.Asset.root:
            endpoint = .get(asset: trunk, tag: tag)

        case "auth":
            endpoint = .get(auth: trunk,
                with: .init(uri.query?.parameters))

        case "articles":
            endpoint = .get(articles: trunk,
                with: .init(uri.query?.parameters),
                tag: tag)

        case Site.Docs.root:
            endpoint = .get(docs: trunk, path,
                with: .init(uri.query?.parameters),
                tag: tag)

        case Site.Guides.root:
            endpoint = .get(guides: trunk,
                with: .init(uri.query?.parameters),
                tag: tag)

        case "lunr":
            endpoint = .get(lunr: trunk,
                with: .init(uri.query?.parameters),
                tag: tag)

        case "sitemaps":
            endpoint = .get(sitemaps: trunk, tag: tag)

        case Site.Tags.root:
            endpoint = .get(tags: trunk,
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

        if  let endpoint:Server.Endpoint
        {
            self.init(endpoint: endpoint, cookies: cookies, profile: profile)
        }
        else
        {
            return nil
        }
    }

    init?(post uri:String,
        address _:SocketAddress?,
        headers:HTTPHeaders,
        body:[UInt8])
    {
        guard let uri:URI = .init(uri)
        else
        {
            return nil
        }

        var path:ArraySlice<String> = uri.path.normalized(lowercase: true)[...]

        guard
        let root:String = path.popFirst(),
        let trunk:String = path.popFirst(),
        let type:Substring = headers[canonicalForm: "content-type"].first,
        let type:ContentType = .init(type)
        else
        {
            return nil
        }

        let cookies:Server.Cookies = .init(headers[canonicalForm: "cookie"])

        let endpoint:Server.Endpoint?

        switch root
        {
        case Site.Admin.root:
            endpoint = try? .post(admin: trunk, path, body: body, type: type)

        case Site.API.root:
            endpoint = try? .post(api: trunk, body: body, type: type)

        case _:
            return nil
        }

        if  let endpoint:Server.Endpoint
        {
            self.init(endpoint: endpoint, cookies: cookies)
        }
        else
        {
            return nil
        }
    }

    init?(put uri:String,
        address _:SocketAddress?,
        headers:HTTPHeaders,
        body:[UInt8])
    {
        guard let uri:URI = .init(uri)
        else
        {
            return nil
        }

        var path:ArraySlice<String> = uri.path.normalized(lowercase: true)[...]

        guard
        let root:String = path.popFirst(),
        let trunk:String = path.popFirst(),
        let type:Substring = headers[canonicalForm: "content-type"].first,
        let type:ContentType = .init(type)
        else
        {
            return nil
        }

        let cookies:Server.Cookies = .init(headers[canonicalForm: "cookie"])

        let endpoint:Server.Endpoint?

        switch root
        {
        case Site.API.root:
            endpoint = try? .put(api: trunk, body: body, type: type)

        case _:
            return nil
        }

        if  let endpoint:Server.Endpoint
        {
            self.init(endpoint: endpoint, cookies: cookies)
        }
        else
        {
            return nil
        }
    }
}
