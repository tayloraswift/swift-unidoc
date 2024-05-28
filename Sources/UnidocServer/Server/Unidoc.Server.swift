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
        rights:Unidoc.UserRights,
        with session:Mongo.Session) async throws -> HTTP.ServerResponse?
    {
        guard case .human = rights.level, self.secure
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

        //  Don’t really have a smarter way to check this except loading the entire package
        //  metadata.
        guard
        let package:Unidoc.PackageMetadata = try await self.db.packages.find(id: package,
            with: session)
        else
        {
            return .notFound("No such package\n")
        }

        if  let owner:Unidoc.Account = package.repo?.account
        {
            let rights:Unidoc.PackageRights = .of(account: account,
                access: rights.access,
                owner: owner)

            if  rights >= .editor
            {
                return nil
            }
        }

        return .forbidden("You are not authorized to edit this package!\n")
    }
}
