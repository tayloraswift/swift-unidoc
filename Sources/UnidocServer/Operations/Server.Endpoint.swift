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

extension Server.Endpoint
{
    struct AuthParameters
    {
        /// Only used for testing, never sent by GitHub.
        var token:String?
        /// Defined and sent by GitHub.
        var state:String?
        /// Defined and sent by GitHub.
        var code:String?

        private
        init()
        {
            self.token = nil
            self.state = nil
            self.code = nil
        }
    }
}
extension Server.Endpoint.AuthParameters
{
    init(_ parameters:[(key:String, value:String)]?)
    {
        self.init()

        guard
        let parameters:[(key:String, value:String)]
        else
        {
            return
        }

        for (key, value):(String, String) in parameters
        {
            switch key
            {
            case "token":   self.token = value
            case "state":   self.state = value
            case "code":    self.code = value
            case _:         continue
            }
        }
    }
}
extension Server.Endpoint
{
    struct LegacyParameters
    {
        var overload:Symbol.Decl?
        var from:String?

        private
        init()
        {
            self.overload = nil
            self.from = nil
        }
    }
}
extension Server.Endpoint.LegacyParameters
{
    init(_ parameters:[(key:String, value:String)]?)
    {
        self.init()

        guard
        let parameters:[(key:String, value:String)]
        else
        {
            return
        }

        for (key, value):(String, String) in parameters
        {
            switch key
            {
            case "overload":    self.overload = .init(rawValue: value)
            case "from":        self.from = value
            case _:             continue
            }
        }
    }
}
extension Server.Endpoint
{
    struct PipelineParameters
    {
        var explain:Bool
        var hash:FNV24?

        private
        init()
        {
            self.explain = false
            self.hash = nil
        }
    }
}
extension Server.Endpoint.PipelineParameters
{
    init(_ parameters:[(key:String, value:String)]?)
    {
        self.init()

        guard
        let parameters:[(key:String, value:String)]
        else
        {
            return
        }

        for (key, value):(String, String) in parameters
        {
            switch key
            {
            case "explain": self.explain = value == "true"
            case "hash":    self.hash = .init(value)
            case _:         continue
            }
        }
    }
}
extension Server
{
    enum Endpoint:Sendable
    {
        case interactive(any InteractiveOperation)
        case stateless(ServerResponse)
        case `static`(Cache<Site.Asset.Get>.Request)
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
            return .stateless(.ok(action.resource()))
        }
        else if trunk == "recode",
            let target:String = stem.first,
            let target:Site.Admin.Recode.Target = .init(rawValue: target)
        {
            return .stateless(.ok(Site.Admin.Recode.init(target: target).resource()))
        }
        else
        {
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
                return .interactive(Server.Operation.Pipeline<PackageEditionsQuery>.init(
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
        let asset:Site.Asset.Get? = .init(trunk)
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
                return .interactive(Server.Operation.Login.init(state: state, code: code))
            }

        case "register":
            if  let token:String = parameters.token
            {
                return .interactive(Server.Operation.Register.init(token: token))
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
        .interactive(Server.Operation.Pipeline<WideQuery>.init(
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
        .interactive(Server.Operation.Pipeline<WideQuery>.init(
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
        .interactive(Server.Operation.Pipeline<ThinQuery<Volume.Range>>.init(
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
            return .interactive(
                Server.Operation.Pipeline<SearchIndexQuery<VolumeIdentifier>>.init(
                output: parameters.explain ? nil : .application(.json),
                query: .init(
                    from: UnidocDatabase.Search.name,
                    tag: tag,
                    id: id),
                tag: tag))
        }
        else if trunk == "packages.json"
        {
            return .interactive(
                Server.Operation.Pipeline<SearchIndexQuery<Int32>>.init(
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
        .interactive(Server.Operation.SiteMap.init(
            package: .init(trunk.prefix { $0 != "." }),
            tag: tag))
    }

    static
    func get(tags trunk:String, with parameters:PipelineParameters, tag:MD5?) -> Self
    {
        .interactive(Server.Operation.Pipeline<PackageEditionsQuery>.init(
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
            return .interactive(Server.Operation.Pipeline<ThinQuery<Symbol.Decl>>.init(
                output: .text(.html),
                query: .init(volume: query.volume, lookup: overload)))
        }
        else
        {
            return .interactive(Server.Operation.Pipeline<ThinQuery<Volume.Shoot>>.init(
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
            return .interactive(Server.Operation.Admin.perform(action, form))
        }
        else if action == "recode",
            let target:String = rest.first,
            let target:Site.Admin.Recode.Target = .init(rawValue: target)
        {
            return .interactive(Server.Operation.Admin.recode(.init(target: target)))
        }
        else
        {
            return nil
        }
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

        switch (trunk, type)
        {
        case (.index, .media(.application(.x_www_form_urlencoded, charset: _))):
            let query:URI.Query = try .parse(parameters: body)
            let form:[String: String] = query.parameters.reduce(into: [:])
            {
                $0[$1.key] = $1.value
            }
            if  let owner:String = form["owner"],
                let repo:String = form["repo"]
            {
                return .interactive(Server.Operation._SyncRepository.init(
                    owner: owner,
                    repo: repo))
            }

        case (_, _):
            break
        }

        return nil
    }
}
