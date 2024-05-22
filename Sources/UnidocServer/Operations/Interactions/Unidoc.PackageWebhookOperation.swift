import GitHubAPI
import HTTP
import JSON
import MongoDB
import SemanticVersions
import UnidocRender

extension Unidoc
{
    struct PackageWebhookOperation:Sendable
    {
        private
        let event:GitHub.WebhookCreate

        private
        init(event:GitHub.WebhookCreate)
        {
            self.event = event
        }
    }
}
extension Unidoc.PackageWebhookOperation
{
    init(parsing body:[UInt8]) throws
    {
        let json:JSON = .init(utf8: body[...])
        self.init(event: try json.decode())
    }
}
extension Unidoc.PackageWebhookOperation:Unidoc.PublicOperation
{
    __consuming
    func load(from server:borrowing Unidoc.Server,
        as format:Unidoc.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        let session:Mongo.Session = try await .init(from: server.db.sessions)
        var event:GitHub.WebhookCreate = self.event

        guard
        let package:Unidoc.PackageMetadata = try await server.db.packages.findGitHub(
            repo: self.event.repo.id,
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

        if  new
        {
            return .resource("", status: 201)
        }
        else
        {
            return .noContent
        }
    }
}
