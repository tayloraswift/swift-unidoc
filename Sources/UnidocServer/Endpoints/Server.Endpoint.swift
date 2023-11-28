import FNV1
import HTTP
import MD5
import Multiparts
import Symbols
import UnidocAutomation
import UnidocDB
import UnidocPages
import UnidocQueries
import UnidocSelectors
import UnidocRecords
import URI

extension Server
{
    enum Endpoint:Sendable
    {
        case interactive(any InteractiveEndpoint)
        case procedural(any ProceduralEndpoint)
        case stateless(any RenderablePage & Sendable)
        case redirect(String)
        case `static`(Cache<StaticAsset>.Request)
    }
}
//  GET endpoints
extension Server.Endpoint
{
    static
    func get(admin trunk:String, _ stem:ArraySlice<String>, tag:MD5?) -> Self?
    {
        if  let action:Site.Admin.Action = .init(rawValue: trunk)
        {
            return .stateless(action)
        }

        switch trunk
        {
        case Site.Admin.Recode.name:
            guard
            let target:String = stem.first
            else
            {
                return .stateless(Site.Admin.Recode.init())
            }

            if  let target:Site.Admin.Recode.Target = .init(rawValue: target)
            {
                return .stateless(target)
            }
            else
            {
                return nil
            }

        case Site.Admin.Slaves.name:
            return .interactive(SlavesDashboard.status)

        case _:
            return nil
        }
    }

    static
    func get(api trunk:String,
        _ stem:ArraySlice<String>,
        with parameters:PipelineParameters,
        tag:MD5?) -> Self?
    {
        guard
        let trunk:UnidocAPI.Get = .init(trunk)
        else
        {
            return nil
        }

        switch trunk
        {
        case .build:
            if  let package:String = stem.first
            {
                return .interactive(Pipeline<Realm.EditionsQuery>.init(
                    output: parameters.explain ? nil : .application(.json),
                    query: .init(package: .init(package), limit: 1),
                    tag: tag))
            }
        }

        return nil
    }

    static
    func get(asset trunk:String, tag:MD5?) -> Self?
    {
        let asset:StaticAsset? = .init(trunk)
        return asset.map { .static(.init($0, tag: tag)) }
    }

    static
    func get(auth trunk:String, with parameters:AuthParameters) -> Self?
    {
        switch trunk
        {
        case "github":
            if  let state:String = parameters.state,
                let code:String = parameters.code
            {
                return .interactive(Login.init(state: state, code: code))
            }

        case "register":
            if  let token:String = parameters.token
            {
                return .interactive(Register.init(token: token))
            }

        case _:
            break
        }

        return nil
    }

    static
    func get(articles trunk:String,
        with parameters:PipelineParameters,
        tag:MD5?) -> Self
    {
        .interactive(Pipeline<Volume.LookupQuery<Volume.LookupAdjacent, Site.Blog>>.init(
            output: parameters.explain ? nil : .text(.html),
            query: .init(
                volume: .init(package: "__swiftinit", version: "0.0.0"),
                lookup: .init(stem: ["Articles", trunk], hash: nil)),
            tag: tag))
    }

    static
    func get(docs trunk:String,
        _ stem:ArraySlice<String>,
        with parameters:PipelineParameters,
        tag:MD5?) -> Self
    {
        let volume:Volume.Selector = .init(trunk)

        //  Special sitemap route.
        //  The '-' in the name means it will never collide with a decl.
        if  case nil = volume.version,
            case "all-symbols"? = stem.first,
            case stem.endIndex = stem.index(after: stem.startIndex)
        {
            return .interactive(Pipeline<Realm.SitemapQuery>.init(
                output: parameters.explain ? nil : .text(.html),
                query: .init(package: volume.package),
                tag: tag))
        }
        else
        {
            let shoot:Volume.Shoot = .init(stem: stem, hash: parameters.hash)

            return .interactive(
                Pipeline<Volume.LookupQuery<Volume.LookupAdjacent, Site.Docs>>.init(
                output: parameters.explain ? nil : .text(.html),
                query: .init(volume: volume, lookup: shoot),
                tag: tag))
        }
    }

    static
    func get(lunr trunk:String,
        with parameters:PipelineParameters,
        tag:MD5?) -> Self?
    {
        if  let id:VolumeIdentifier = .init(trunk)
        {
            return .interactive(Pipeline<SearchIndexQuery<VolumeIdentifier>>.init(
                output: parameters.explain ? nil : .application(.json),
                query: .init(
                    from: UnidocDatabase.Search.name,
                    tag: tag,
                    id: id),
                tag: tag))
        }
        else if trunk == "packages.json"
        {
            return .interactive(Pipeline<SearchIndexQuery<Int32>>.init(
                output: parameters.explain ? nil : .application(.json),
                query: .init(
                    from: UnidocDatabase.Metadata.name,
                    tag: tag,
                    id: 0),
                tag: tag))
        }

        return nil
    }

    static
    func get(stats trunk:String,
        _ stem:ArraySlice<String>,
        with parameters:PipelineParameters,
        tag:MD5?) -> Self
    {
        let volume:Volume.Selector = .init(trunk)
        let shoot:Volume.Shoot = .init(stem: stem, hash: parameters.hash)

        return .interactive(
            Pipeline<Volume.LookupQuery<Volume.LookupAdjacent, Site.Stats>>.init(
            output: parameters.explain ? nil : .text(.html),
            query: .init(volume: volume, lookup: shoot),
            tag: tag))
    }

    static
    func get(tags trunk:String, with parameters:PipelineParameters, tag:MD5?) -> Self
    {
        .interactive(Pipeline<Realm.EditionsQuery>.init(
            output: parameters.explain ? nil : .text(.html),
            query: .init(package: .init(trunk), limit: 12),
            tag: tag))
    }

    static
    func get(
        legacy trunk:String,
        _ stem:ArraySlice<String>,
        with parameters:LegacyParameters) -> Self
    {
        let query:Volume.RedirectQuery<Volume.Shoot> = .legacy(head: trunk,
            rest: stem,
            from: parameters.from)

        if  let overload:Symbol.Decl = parameters.overload
        {
            return .interactive(Pipeline<Volume.RedirectQuery<Symbol.Decl>>.init(
                output: .text(.html),
                query: .init(volume: query.volume, lookup: overload)))
        }
        else
        {
            return .interactive(Pipeline<Volume.RedirectQuery<Volume.Shoot>>.init(
                output: .text(.html),
                query: query))
        }
    }
}

//  POST endpoints
extension Server.Endpoint
{
    static
    func post(admin action:String, _ rest:ArraySlice<String>,
        body:consuming [UInt8],
        type:ContentType) throws -> Self?
    {
        if  let action:Site.Admin.Action = .init(rawValue: action),
            case  .multipart(.form_data(boundary: let boundary?)) = type
        {
            let form:MultipartForm = try .init(splitting: body, on: boundary)
            return .interactive(Admin.perform(action, form))
        }

        switch action
        {
        case Site.Admin.Recode.name:
            if  let target:String = rest.first,
                let target:Site.Admin.Recode.Target = .init(rawValue: target)
            {
                return .interactive(Admin.recode(target))
            }

        case Site.Admin.Slaves.name:
            return .interactive(SlavesDashboard.scramble)

        case _:
            break
        }

        return nil
    }

    static
    func post(api trunk:String,
        body:consuming [UInt8],
        type:ContentType) throws -> Self?
    {
        guard
        let trunk:UnidocAPI.Post = .init(trunk)
        else
        {
            return nil
        }

        switch type
        {
        case .media(.application(.x_www_form_urlencoded, charset: _)):
            let query:URI.Query = try .parse(parameters: body)
            let form:[String: String] = query.parameters.reduce(into: [:])
            {
                $0[$1.key] = $1.value
            }

            switch trunk
            {
            case .indexRepo:
                if  let owner:String = form["owner"],
                    let repo:String = form["repo"]
                {
                    return .interactive(IndexRepo.init(owner: owner, repo: repo))
                }

            case .indexRepoTag:
                if  let package:String = form["package"],
                    let tag:String = form["tag"]
                {
                    let package:Symbol.Package = .init(package)
                    return .interactive(IndexRepoTag.init(package: package, tag: tag))
                }

            case .uplink:
                if  let package:String = form["package"],
                    let package:Int32 = .init(package),
                    let version:String = form["version"],
                    let version:Int32 = .init(version)
                {
                    return .procedural(GraphUplink.coordinate(.init(
                        package: package,
                        version: version)))
                }
                else if
                    let volume:String = form["volume"],
                    let volume:VolumeIdentifier = .init(volume)
                {
                    return .procedural(GraphUplink.identifier(volume))
                }

            case .unlink:
                if  let volume:String = form["volume"],
                    let volume:VolumeIdentifier = .init(volume)
                {
                    return .procedural(GraphUnlink.init(volume: volume))
                }
            }

            fallthrough

        case _:
            return nil
        }
    }
}

//  PUT endpoints
extension Server.Endpoint
{
    static
    func put(api trunk:String, type:ContentType) throws -> Self?
    {
        guard
        let trunk:UnidocAPI.Put = .init(trunk)
        else
        {
            return nil
        }

        switch (trunk, type)
        {
        case (.snapshot, .media(.application(.bson, charset: nil))):
            return .procedural(Server.Endpoint.GraphStorage.put)

        case (.graph, .media(.application(.bson, charset: nil))):
            return .procedural(Server.Endpoint.GraphPlacement.put)

        case (_, _):
            return nil
        }
    }
}
