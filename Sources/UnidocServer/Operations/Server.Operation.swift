import HTTPServer
import Media
import MD5
import Multiparts
import NIOCore
import NIOHTTP1
import UnidocDB
import UnidocPages
import UnidocQueries
import URI

extension Server
{
    struct Operation:Sendable
    {
        let endpoint:Endpoint
        let cookies:Cookies

        init(endpoint:Endpoint, cookies:Cookies)
        {
            self.endpoint = endpoint
            self.cookies = cookies
        }
    }
}
extension Server.Operation:HTTPServerOperation
{
    init?(get uri:String,
        address _:SocketAddress?,
        headers:HTTPHeaders)
    {
        guard let uri:URI = .init(uri)
        else
        {
            return nil
        }

        let cookies:Server.Cookies = .init(headers[canonicalForm: "cookie"])
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

            self.init(endpoint: get, cookies: cookies)
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

            self.init(endpoint: endpoint, cookies: cookies)
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
            self.init(endpoint: endpoint, cookies: cookies)
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
