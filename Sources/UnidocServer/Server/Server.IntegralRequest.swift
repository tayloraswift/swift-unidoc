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

extension Server
{
    struct IntegralRequest:Sendable
    {
        let endpoint:Endpoint

        let cookies:Cookies
        var profile:ServerProfile.Sample

        init(endpoint:Endpoint, cookies:Cookies, profile:ServerProfile.Sample)
        {
            self.endpoint = endpoint
            self.cookies = cookies
            self.profile = profile
        }
    }
}
extension Server.IntegralRequest:HTTP.ServerIntegralRequest
{
    init?(get path:String,
        headers:HTTPHeaders,
        address:IP.V6)
    {
        self.init(get: path,
            headers: .init(httpHeaders: headers),
            address: address)

        //  None of the other methods support HTTP/1.1
        self.profile.http2 = false
    }

    init?(get path:String,
        headers:HPACKHeaders,
        address:IP.V6)
    {
        guard let uri:URI = .init(path)
        else
        {
            return nil
        }

        let cookies:Server.Cookies = .init(headers["cookie"])

        let profile:ServerProfile.Sample = .init(ip: address,
            language: headers["accept-language"].first,
            referer: headers["referer"].first,
            agent: headers["user-agent"].last,
            uri: path)

        let tag:MD5? = headers.ifNoneMatch.first.flatMap(MD5.init(_:))

        var path:ArraySlice<String> = uri.path.normalized(lowercase: true)[...]

        guard
        let root:String = path.popFirst()
        else
        {
            let parameters:Server.Endpoint.PipelineParameters = .init(uri.query?.parameters)

            self.init(endpoint: .interactive(Server.Endpoint.Pipeline<RecentActivityQuery>.init(
                    output: parameters.explain ? nil : .text(.html),
                    query: .init(limit: 16),
                    tag: tag)),
                cookies: cookies,
                profile: profile)

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
                endpoint = .interactive(Server.Endpoint.Robots.init())

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

        if  let endpoint:Server.Endpoint
        {
            self.init(endpoint: endpoint, cookies: cookies, profile: profile)
        }
        else
        {
            return nil
        }
    }
    init?(post path:String,
        headers:HPACKHeaders,
        address:IP.V6,
        body:[UInt8])
    {
        guard let uri:URI = .init(path)
        else
        {
            return nil
        }

        let profile:ServerProfile.Sample = .init(ip: address, uri: path)

        var path:ArraySlice<String> = uri.path.normalized(lowercase: true)[...]

        guard
        let root:String = path.popFirst(),
        let trunk:String = path.popFirst(),
        let type:String = headers["content-type"].first,
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

        case UnidocAPI.root:
            endpoint = try? .post(api: trunk, body: body, type: type)

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
}
