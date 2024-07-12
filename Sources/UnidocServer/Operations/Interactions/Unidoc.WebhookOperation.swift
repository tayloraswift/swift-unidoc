import GitHubAPI
import HTTP
import IP
import JSON
import MongoDB
import SemanticVersions
import UnidocRender
import UnixTime

extension Unidoc
{
    struct WebhookOperation:Sendable
    {
        private
        let event:Event
        private
        let hook:UInt

        private
        init(event:Event, hook:UInt)
        {
            self.event = event
            self.hook = hook
        }
    }
}
extension Unidoc.WebhookOperation
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
        default:        throw Unidoc.WebhookError.unverifiedOrigin
        }

        let hook:String?
        let type:String?

        switch headers
        {
        case .http1_1(let headers):
            hook = headers["X-GitHub-Hook-ID"].first
            type = headers["X-GitHub-Event"].first

        case .http2(let headers):
            hook = headers["X-GitHub-Hook-ID"].first
            type = headers["X-GitHub-Event"].first
        }

        guard
        let type:String
        else
        {
            throw Unidoc.WebhookError.missingEventType
        }
        guard
        let hook:String
        else
        {
            throw Unidoc.WebhookError.missingHookID
        }
        guard
        let hook:UInt = .init(hook)
        else
        {
            throw Unidoc.WebhookError.invalidHookID
        }

        let event:Event

        switch type
        {
        case "installation":    event = .installation(try json.decode())
        case "create":          event = .create(try json.decode())
        case let type:          event = .ignore(type)
        }

        self.init(event: event, hook: hook)
    }
}
extension Unidoc.WebhookOperation:Unidoc.PublicOperation
{
    __consuming
    func load(from server:Unidoc.Server,
        as format:Unidoc.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        switch self.event
        {
        case .installation(let event):
            return try await self.handle(installation: event,
                in: server.db,
                at: .init(truncating: format.time))

        case .create(let event):
            return try await self.handle(create: event,
                in: server.db,
                at: .init(truncating: format.time))

        case .ignore(let type):
            return .ok("Ignored event type '\(type)'\n")
        }
    }
}
extension Unidoc.WebhookOperation
{
    private __consuming
    func handle(installation event:GitHub.WebhookInstallation,
        in db:Unidoc.Database,
        at time:UnixMillisecond) async throws -> HTTP.ServerResponse
    {
        guard case .created = event.action
        else
        {
            return .ok("")
        }

        let user:Unidoc.User = .init(githubInstallation: event.installation,
            initialLimit: db.policy.apiLimitPerReset)
        let session:Mongo.Session = try await .init(from: db.sessions)
        let _:Unidoc.UserSecrets = try await db.users.update(user: user, with: session)
        return .created("")
    }

    private __consuming
    func handle(create event:GitHub.WebhookCreate,
        in db:Unidoc.Database,
        at time:UnixMillisecond) async throws -> HTTP.ServerResponse
    {
        let repo:Unidoc.PackageRepo = try .github(event.repo, crawled: time)

        let indexEligible:Bool
        let repoWebhook:String

        if  let id:Int32 = event.installation
        {
            if  case .private = event.repo.visibility
            {
                //  This is our only chance to index a private repository.
                indexEligible = true
            }
            else if
                case "Swift"? = event.repo.language,
                repo.origin.alive,
                repo.stars > 1
            {
                //  If the repo is public, has more than one star, and contains enough Swift
                //  code for GitHub to recognize it as a Swift project, we will also take this
                //  opportunity to index it.
                indexEligible = true
            }
            else
            {
                indexEligible = false
            }

            repoWebhook = "github.com/settings/installations/\(id)"
        }
        else
        {
            /// This webhook was installed directly on a repository. We can be reasonably
            /// confident that the owner intended to index this package.
            indexEligible = true
            repoWebhook = """
            github.com/\(event.repo.owner.login)/\(event.repo.name)/settings/hooks/\(self.hook)
            """
        }

        let session:Mongo.Session = try await .init(from: db.sessions)
        let package:Unidoc.PackageMetadata

        if  let known:Unidoc.PackageMetadata = try await db.packages.updateWebhook(
                configurationURL: repoWebhook,
                repo: repo,
                with: session)
        {
            package = known
        }
        else if indexEligible
        {
            (package, _) = try await db.unidoc.index(
                package: "\(event.repo.owner.login).\(event.repo.name)",
                repo: repo,
                repoWebhook: repoWebhook,
                mode: .automatic,
                with: session)
        }
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

        let (_, new):(Unidoc.EditionMetadata, new:Bool) = try await db.unidoc.index(
            package: package.id,
            version: version,
            name: event.ref,
            sha1: nil,
            with: session)

        //  If we got this far, we should destroy any crawling tickets this package has.
        _ = try? await db.crawlingTickets.delete(id: package.id, with: session)

        guard new
        else
        {
            return .noContent
        }

        if !package.hidden
        {
            let activity:Unidoc.DB.RepoFeed.Activity = .init(
                discovered: time,
                package: package.symbol,
                refname: event.ref)

            try await db.repoFeed.push(activity, with: session)
        }

        return .created("")
    }
}
