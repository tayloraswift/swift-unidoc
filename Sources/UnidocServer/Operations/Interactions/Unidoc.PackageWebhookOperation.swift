import GitHubAPI
import HTTP
import IP
import JSON
import MongoDB
import SemanticVersions
import UnidocRender

extension Unidoc
{
    enum PackageWebhookOperation:Sendable
    {
        case create(GitHub.WebhookCreate)
        case ignore(String)
    }
}
extension Unidoc.PackageWebhookOperation
{
    init(json:JSON, from origin:IP.Origin, with headers:__shared HTTP.Headers) throws
    {
        //  Did this request actually come from GitHub? (Anyone can POST over HTTP/2.)
        //
        //  FIXME: there is a security hole during the (hopefully brief) interval between
        //  when the server restarts and the whitelists are initialized.
        switch origin.owner
        {
        case .github:   break
        case .unknown:  break
        default:        throw Unidoc.PackageWebhookError.unverifiedOrigin
        }

        let type:String?

        switch headers
        {
        case .http1_1(let headers): type = headers["X-GitHub-Event"].first
        case .http2(let headers):   type = headers["X-GitHub-Event"].first
        }

        switch type
        {
        case "create"?:
            self = .create(try json.decode())

        case let type?:
            self = .ignore(type)

        case nil:
            throw Unidoc.PackageWebhookError.missingEventType
        }

    }
}
extension Unidoc.PackageWebhookOperation:Unidoc.PublicOperation
{
    __consuming
    func load(from server:borrowing Unidoc.Server,
        as format:Unidoc.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        var event:GitHub.WebhookCreate
        switch self
        {
        case .create(let value):    event = value
        case .ignore(let type):     return .ok("Ignored event type '\(type)'\n")
        }

        let session:Mongo.Session = try await .init(from: server.db.sessions)

        guard
        let package:Unidoc.PackageMetadata = try await server.db.packages.findGitHub(
            repo: event.repo.id,
            with: session)
        else
        {
            return .notFound("No such package\n")
        }

        guard case .tag = event.refType,
        let version:SemanticVersion = package.symbol.version(tag: event.ref)
        else
        {
            return .ok("Ignored ref '\(event.ref)' because it is not a semantic version\n")
        }

        //  TODO: see if we can also perform a package metadata update
        if  case .github(let origin)? = package.repo?.origin
        {
            event.repo.watchers = origin.watchers
        }

        let (_, new):(Unidoc.EditionMetadata, new:Bool) = try await server.db.unidoc.index(
            package: package.id,
            version: version,
            name: event.ref,
            sha1: nil,
            with: session)

        guard new
        else
        {
            return .noContent
        }

        if !package.hidden
        {
            let activity:Unidoc.DB.RepoFeed.Activity = .init(discovered: .init(format.time),
                package: package.symbol,
                refname: event.ref)

            try await server.db.repoFeed.push(activity, with: session)
        }

        return .resource("", status: 201)
    }
}
