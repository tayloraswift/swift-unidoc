import GitHubClient
import GitHubIntegration
import HTTP
import ModuleGraphs
import MongoDB
import UnidocDatabase

extension Server.Endpoint
{
    struct _SyncRepository:Sendable
    {
        let package:PackageIdentifier
    }
}
extension Server.Endpoint._SyncRepository:RestrictedOperation
{
    func load(from services:Services) async throws -> ServerResponse?
    {
        let session:Mongo.Session = try await .init(from: services.database.sessions)

        let packages:PackageDatabase = services.database.packages
        let editions:[PackageEdition] = try await packages.editions(of: package, with: session)
        return .resource(.init(.one(canonical: nil),
            content: .string("\(editions)"),
            type: .text(.plain, charset: .utf8)))
    }
}
