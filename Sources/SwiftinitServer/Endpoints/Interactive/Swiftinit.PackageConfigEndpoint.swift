import HTTP
import MongoDB
import UnidocDB

extension Swiftinit
{
    struct PackageConfigEndpoint:Sendable
    {
        let package:Unidoc.Package
        let update:Update

        init(package:Unidoc.Package, update:Update)
        {
            self.package = package
            self.update = update
        }
    }
}
extension Swiftinit.PackageConfigEndpoint:RestrictedEndpoint
{
    func load(from server:borrowing Swiftinit.Server) async throws -> HTTP.ServerResponse?
    {
        let session:Mongo.Session = try await .init(from: server.db.sessions)
        let updated:Unidoc.PackageMetadata?
        switch self.update
        {
        case .hidden(let hidden):
            updated = try await server.db.packages.update(package: self.package,
                hidden: hidden,
                with: session)
        }

        guard
        let updated:Unidoc.PackageMetadata
        else
        {
            return .notFound("No such package")
        }

        try await server.db.unidoc.rebuildPackageList(with: session)
        return .redirect(.see(other: "\(Swiftinit.Tags[updated.symbol])"))
    }
}
