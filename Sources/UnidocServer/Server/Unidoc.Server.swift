import GitHubAPI
import HTTP
import MongoDB
import UnidocRender

extension Unidoc
{
    @frozen public
    struct Server:~Copyable
    {
        @usableFromInline
        let loop:ServerLoop
        @usableFromInline
        let tour:ServerTour

        init(_ loop:ServerLoop, tour:ServerTour)
        {
            self.loop = loop
            self.tour = tour
        }
    }
}
extension Unidoc.Server
{
    @inlinable public
    var security:Unidoc.ServerSecurity { self.loop.security }

    @inlinable public
    var plugins:[String: any Unidoc.ServerPlugin] { self.loop.plugins }
    @inlinable public
    var context:Unidoc.ServerPluginContext { self.loop.context }

    @inlinable public
    var github:GitHub.Integration? { self.loop.github }
    @inlinable public
    var bucket:Unidoc.Buckets { self.loop.bucket }

    @inlinable public
    var format:Unidoc.RenderFormat { self.loop.format }
    @inlinable public
    var db:Unidoc.Database { self.loop.db }
}
extension Unidoc.Server
{
    func authorize(package preloaded:Unidoc.PackageMetadata? = nil,
        loading id:Unidoc.Package,
        account:Unidoc.Account?,
        rights:Unidoc.UserRights,
        require minimum:Unidoc.PackageRights = .editor,
        with session:Mongo.Session) async throws -> HTTP.ServerResponse?
    {
        guard
        case .enforced = self.security,
        case .human = rights.level
        else
        {
            //  Only enforce ownership rules for humans.
            return nil
        }

        guard
        let account:Unidoc.Account
        else
        {
            return .unauthorized("You must be logged in to perform this operation!\n")
        }

        let package:Unidoc.PackageMetadata

        if  let preloaded:Unidoc.PackageMetadata
        {
            package = preloaded
        }
        else if
            let metadata:Unidoc.PackageMetadata = try await self.db.packages.find(id: id,
                with: session)
        {
            package = metadata
        }
        else
        {
            return .notFound("No such package\n")
        }

        let rights:Unidoc.PackageRights = .of(account: account,
            access: rights.access,
            rulers: package.rulers)

        if  rights >= minimum
        {
            return nil
        }

        return .forbidden("You are not authorized to edit this package!\n")
    }
}
