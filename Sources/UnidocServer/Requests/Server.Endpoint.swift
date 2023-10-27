import FNV1
import HTTP
import MD5
import ModuleGraphs
import Multiparts
import Symbols
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
        let trunk:Site.API.Get = .init(trunk)
        else
        {
            return nil
        }

        switch trunk
        {
        case .build:
            if  let package:String = stem.first
            {
                return .interactive(Pipeline<PackageEditionsQuery>.init(
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
        .interactive(Pipeline<WideQuery>.init(
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
        .interactive(Pipeline<WideQuery>.init(
            output: parameters.explain ? nil : .text(.html),
            query: .init(
                volume: .init(trunk),
                lookup: .init(stem: stem, hash: parameters.hash)),
            tag: tag))
    }

    static
    func get(guides trunk:String,
        with parameters:PipelineParameters,
        tag:MD5?) -> Self
    {
        .interactive(Pipeline<ThinQuery<Volume.Range>>.init(
            output: parameters.explain ? nil : .text(.html),
            query: .init(
                volume: .init(trunk),
                lookup: .articles),
            tag: tag))
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
                    from: UnidocDatabase.Meta.name,
                    tag: tag,
                    id: 0),
                tag: tag))
        }

        return nil
    }

    static
    func get(sitemaps trunk:String, tag:MD5?) -> Self
    {
        //  Ignore file extension.
        .interactive(SiteMap.init(
            package: .init(trunk.prefix { $0 != "." }),
            tag: tag))
    }

    static
    func get(tags trunk:String, with parameters:PipelineParameters, tag:MD5?) -> Self
    {
        .interactive(Pipeline<PackageEditionsQuery>.init(
            output: parameters.explain ? nil : .text(.html),
            query: .init(package: .init(trunk)),
            tag: tag))
    }

    static
    func get(
        legacy trunk:String,
        _ stem:ArraySlice<String>,
        with parameters:LegacyParameters) -> Self
    {
        let query:ThinQuery<Volume.Shoot> = .legacy(head: trunk,
            rest: stem,
            from: parameters.from)

        if  let overload:Symbol.Decl = parameters.overload
        {
            return .interactive(Pipeline<ThinQuery<Symbol.Decl>>.init(
                output: .text(.html),
                query: .init(volume: query.volume, lookup: overload)))
        }
        else
        {
            return .interactive(Pipeline<ThinQuery<Volume.Shoot>>.init(
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
        body:[UInt8],
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
        body:[UInt8],
        type:ContentType) throws -> Self?
    {
        guard
        let trunk:Site.API.Post = .init(trunk)
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
            case .index:
                if  let owner:String = form["owner"],
                    let repo:String = form["repo"]
                {
                    return .interactive(_SyncRepository.init(
                        owner: owner,
                        repo: repo))
                }

            case .uplink:
                if  let package:String = form["package"],
                    let package:Int32 = .init(package),
                    let version:String = form["version"],
                    let version:Int32 = .init(version)
                {
                    return .procedural(GraphUplink.coordinate(package, version))
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
        let trunk:Site.API.Put = .init(trunk)
        else
        {
            return nil
        }

        switch (trunk, type)
        {
        case (.symbolgraph, .media(.application(.bson, charset: nil))):
            return .procedural(Server.Endpoint.GraphStorage.put)

        case (_, _):
            return nil
        }
    }
}
