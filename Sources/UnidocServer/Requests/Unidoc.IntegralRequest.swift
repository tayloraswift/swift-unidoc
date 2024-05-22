import MD5
import Multiparts
import URI

extension Unidoc
{
    @frozen public
    struct IntegralRequest:Sendable
    {
        public
        let metadata:Metadata
        public
        let ordering:Ordering

        private
        init(metadata:Metadata, ordering:Ordering)
        {
            self.metadata = metadata
            self.ordering = ordering
        }
    }
}
extension Unidoc.IntegralRequest
{
    public
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
            let parameters:Unidoc.PipelineParameters = .init(uri.query?.parameters)

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
            case Unidoc.ServerRoot.account.id:
                guard
                let user:Unidoc.UserSession = metadata.cookies.session
                else
                {
                    ordering = .syncRedirect(.temporary("\(Unidoc.ServerRoot.login)"))
                    break
                }

                ordering = .explainable(Unidoc.UserSettingsEndpoint.init(
                        query: .init(session: user)),
                    parameters: .init(uri.query?.parameters, tag: tag))

            case Unidoc.ServerRoot.admin.id:
                ordering = .actor(Unidoc.LoadDashboardOperation.master)

            case Unidoc.ServerRoot.login.id:
                ordering = .actor(Unidoc.LoginOperation.init(flow: .sso))

            case "robots.txt":
                let parameters:Unidoc.PipelineParameters = .init(uri.query?.parameters,
                    tag: tag)

                ordering = .explainable(Unidoc.TextEndpoint.init(query: .init(
                        tag: parameters.tag,
                        id: .robots_txt)),
                    parameters: parameters)

            case "sitemap.xml":
                ordering = .actor(Unidoc.LoadSitemapIndexOperation.init(tag: tag))

            case Unidoc.ServerRoot.ssgc.id:
                guard
                let query:URI.Query = uri.query,
                let build:Unidoc.BuildLabelsPrompt = .init(query: query)
                else
                {
                    return nil
                }

                ordering = .actor(Unidoc.BuilderLabelOperation.init(prompt: build))

            case _:
                return nil
            }

            self.init(metadata: metadata, ordering: ordering)
            return
        }

        let ordering:Ordering?

        switch root
        {
        case Unidoc.ServerRoot.admin.id:
            ordering = .get(admin: trunk, path, tag: tag)

        case Unidoc.ServerRoot.asset.id:
            ordering = .get(asset: trunk, tag: tag)

        case Unidoc.ServerRoot.auth.id:
            ordering = .get(auth: trunk,
                with: .init(uri.query?.parameters))

        case Unidoc.ServerRoot.blog.id:
            ordering = .get(blog: "Articles", trunk,
                with: .init(uri.query?.parameters, tag: tag))

        case Unidoc.ServerRoot.docs.id, Unidoc.ServerRoot.docc.id, Unidoc.ServerRoot.hist.id:
            ordering = .get(docs: trunk, path,
                with: .init(uri.query?.parameters, tag: tag))

        case Unidoc.ServerRoot.help.id:
            ordering = .get(blog: "Help", trunk,
                with: .init(uri.query?.parameters, tag: tag))

        case Unidoc.ServerRoot.lunr.id:
            ordering = .get(lunr: trunk,
                with: .init(uri.query?.parameters, tag: tag))

        case Unidoc.ServerRoot.plugin.id:
            ordering = .actor(Unidoc.LoadDashboardOperation.plugin(trunk))

        case Unidoc.ServerRoot.ptcl.id:
            ordering = .get(ptcl: trunk, path,
                with: .init(uri.query?.parameters, tag: tag))

        case Unidoc.ServerRoot.realm.id:
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

            ordering = .actor(Unidoc.UserRenderOperation.init(volume: .init(trunk),
                shoot: .init(path: path),
                query: uri.query?.parameters))

        //  Deprecated route.
        case "sitemaps":
            ordering = .syncRedirect(.permanent("""
                \(Unidoc.ServerRoot.docs)/\(trunk.prefix { $0 != "." })/all-symbols
                """))

        case Unidoc.ServerRoot.ssgc.id:
            guard trunk == "poll",
            let user:Unidoc.UserSession = metadata.cookies.session
            else
            {
                return nil
            }

            ordering = .actor(Unidoc.BuilderPollOperation.init(id: user.account))

        case Unidoc.ServerRoot.stats.id:
            ordering = .get(stats: trunk, path,
                with: .init(uri.query?.parameters, tag: tag))

        case Unidoc.ServerRoot.tags.id:
            ordering = .get(tags: trunk,
                with: .init(uri.query?.parameters,
                    //  OK to do this, if someone forges a cookie, they can see the admin
                    //  controls, but they can't do anything with them.
                    user: metadata.cookies.session?.account,
                    tag: tag))

        case Unidoc.ServerRoot.telescope.id:
            ordering = .get(telescope: trunk,
                with: .init(uri.query?.parameters, tag: tag))

        case Unidoc.ServerRoot.user.id:
            ordering = .get(user: trunk,
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

    public
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

        let ordering:Unidoc.IntegralRequest.Ordering?

        if  let trunk:String = path.popFirst()
        {
            switch root
            {
            case Unidoc.ServerRoot.admin.id:
                ordering = try? .post(admin: trunk, path, body: body, type: type)

            case Unidoc.ServerRoot.api.id:
                ordering = try? .post(api: trunk,
                    body: body,
                    type: type,
                    user: metadata.cookies.session?.account)

            case Unidoc.ServerRoot.hook.id:
                ordering = .post(hook: trunk, body: body, type: type, from: metadata.origin)

            case Unidoc.ServerRoot.really.id:
                ordering = try? .post(really: trunk, body: body, type: type)

            case _:
                return nil
            }
        }
        else if Unidoc.ServerRoot.login.id == root,
            let query:URI.Query = try? .parse(parameters: body),
            let path:String = query.parameters.first?.value
        {
            ordering = .actor(Unidoc.LoginOperation.init(flow: .sso, from: path))
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
