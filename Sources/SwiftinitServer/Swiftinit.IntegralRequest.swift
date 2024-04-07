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
        let metadata:Metadata
        let ordering:Ordering

        init(metadata:Metadata, ordering:Ordering)
        {
            self.metadata = metadata
            self.ordering = ordering
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
        case .robot(.discoursebot): break
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
                metadata: metadata,
                ordering: .explainable(Unidoc.HomeEndpoint.init(query: .init(limit: 16)),
                    parameters: parameters))

            return
        }

        guard
        let trunk:String = path.popFirst()
        else
        {
            let ordering:Ordering

            switch root
            {
            case Swiftinit.Root.account.id:
                guard
                let user:Unidoc.UserSession = metadata.cookies.session
                else
                {
                    ordering = .syncRedirect(.temporary("\(Swiftinit.Root.login)"))
                    break
                }

                ordering = .explainable(Unidoc.UserEndpoint.init(
                        query: .init(session: user)),
                    parameters: .init(uri.query?.parameters, tag: tag))

            case Swiftinit.Root.admin.id:
                ordering = .actor(Swiftinit.DashboardEndpoint.master)

            case Swiftinit.Root.login.id:
                ordering = .actor(Swiftinit.LoginEndpoint.init())

            case "robots.txt":
                let parameters:Swiftinit.PipelineParameters = .init(uri.query?.parameters,
                    tag: tag)

                ordering = .explainable(Unidoc.TextEndpoint.init(query: .init(
                        tag: parameters.tag,
                        id: .robots_txt)),
                    parameters: parameters)

            case "sitemap.xml":
                ordering = .actor(Swiftinit.SitemapIndexEndpoint.init(tag: tag))

            case Swiftinit.Root.ssgc.id:
                guard
                let query:URI.Query = uri.query,
                let build:Unidoc.BuildLabelsPrompt = .init(query: query)
                else
                {
                    return nil
                }

                ordering = .actor(Swiftinit.BuilderLabelEndpoint.init(prompt: build))

            case _:
                return nil
            }

            self.init(metadata: metadata, ordering: ordering)
            return
        }

        let ordering:Ordering?

        switch root
        {
        case Swiftinit.Root.admin.id:
            ordering = .get(admin: trunk, path, tag: tag)

        case Swiftinit.Root.asset.id:
            ordering = .get(asset: trunk, tag: tag)

        case "auth":
            ordering = .get(auth: trunk,
                with: .init(uri.query?.parameters))

        case Swiftinit.Root.blog.id:
            ordering = .get(blog: "Articles", trunk,
                with: .init(uri.query?.parameters, tag: tag))

        case Swiftinit.Root.docs.id, Swiftinit.Root.docc.id, Swiftinit.Root.hist.id:
            ordering = .get(docs: trunk, path,
                with: .init(uri.query?.parameters, tag: tag))

        case Swiftinit.Root.help.id:
            ordering = .get(blog: "Help", trunk,
                with: .init(uri.query?.parameters, tag: tag))

        case Swiftinit.Root.lunr.id:
            ordering = .get(lunr: trunk,
                with: .init(uri.query?.parameters, tag: tag))

        case Swiftinit.Root.plugin.id:
            ordering = .actor(Swiftinit.DashboardEndpoint.plugin(trunk))

        case Swiftinit.Root.ptcl.id:
            ordering = .get(ptcl: trunk, path,
                with: .init(uri.query?.parameters, tag: tag))

        case Swiftinit.Root.realm.id:
            ordering = .get(realm: trunk,
                with: .init(uri.query?.parameters, tag: tag))

        case "render":
            guard metadata.hostSupportsPublicAPI
            else
            {
                ordering = .syncRedirect(.permanent(
                    external: "https://api.swiftinit.org/render"))
                break
            }

            ordering = .actor(Swiftinit.UserRenderEndpoint.init(volume: .init(trunk),
                shoot: .init(path: path),
                query: uri.query?.parameters))

        //  Deprecated route.
        case "sitemaps":
            ordering = .syncRedirect(.permanent("""
                \(Swiftinit.Root.docs)/\(trunk.prefix { $0 != "." })/all-symbols
                """))

        case Swiftinit.Root.ssgc.id:
            guard trunk == "poll",
            let user:Unidoc.UserSession = metadata.cookies.session
            else
            {
                return nil
            }

            ordering = .actor(Swiftinit.BuilderPollEndpoint.init(id: user.account))

        case Swiftinit.Root.stats.id:
            ordering = .get(stats: trunk, path,
                with: .init(uri.query?.parameters, tag: tag))

        case Swiftinit.Root.tags.id:
            ordering = .get(tags: trunk,
                with: .init(uri.query?.parameters,
                    //  OK to do this, if someone forges a cookie, they can see the admin
                    //  controls, but they can't do anything with them.
                    user: metadata.cookies.session?.account,
                    tag: tag))

        case Swiftinit.Root.telescope.id:
            ordering = .get(telescope: trunk,
                with: .init(uri.query?.parameters, tag: tag))

        case "reference":
            ordering = .get(legacy: trunk, path,
                with: .init(uri.query?.parameters))

        case "learn":
            ordering = .get(legacy: trunk, path,
                with: .init(uri.query?.parameters))

        case _:
            return nil
        }

        if  let ordering:Ordering
        {
            self.init(metadata: metadata, ordering: ordering)
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
        let root:String = path.popFirst()
        else
        {
            return nil
        }

        let ordering:Swiftinit.IntegralRequest.Ordering?

        if  let trunk:String = path.popFirst()
        {
            switch root
            {
            case Swiftinit.Root.admin.id:
                ordering = try? .post(admin: trunk, path, body: body, type: type)

            case Swiftinit.Root.api.id:
                ordering = try? .post(api: trunk,
                    body: body,
                    type: type,
                    user: metadata.cookies.session?.account)

            case Swiftinit.Root.really.id:
                ordering = try? .post(really: trunk, body: body, type: type)

            case _:
                return nil
            }
        }
        else if Swiftinit.Root.login.id == root,
            let query:URI.Query = try? .parse(parameters: body),
            let path:String = query.parameters.first?.value
        {
            ordering = .actor(Swiftinit.LoginEndpoint.init(from: path))
        }
        else
        {
            return nil
        }

        if  let ordering:Ordering
        {
            self.init(metadata: metadata, ordering: ordering)
        }
        else
        {
            return nil
        }
    }
}
