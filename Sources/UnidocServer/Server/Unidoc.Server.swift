import GitHubAPI
import HTTP
import MongoDB
import UnidocRender
import UnidocProfiling

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
    var plugins:[String: any Unidoc.ServerPlugin] { self.loop.plugins }
    @inlinable public
    var context:Unidoc.ServerPluginContext { self.loop.context }

    @inlinable public
    var secure:Bool { self.loop.secure }

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
    func authorize(package:Unidoc.Package,
        account:Unidoc.Account?,
        level:Unidoc.User.Level,
        with session:Mongo.Session) async throws -> HTTP.ServerResponse?
    {
        guard
        let id:Unidoc.Account = account
        else
        {
            return self.secure ? .unauthorized("""
                You must be logged in to perform this operation!
                """) : nil
        }

        guard
        let rights:Unidoc.PackageRights = try await self.db.unidoc.rights(account: id,
            package: package,
            with: session)
        else
        {
            return .notFound("No such package")
        }

        if  case .human = level, rights < .editor
        {
            return .forbidden("You are not authorized to edit this package!")
        }
        else
        {
            return nil
        }
    }
}
