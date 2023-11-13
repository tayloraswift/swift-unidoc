import HTTP
import HTTPServer
import MongoDB
import UnidocDB
import UnidocRecords

extension Server.Endpoint
{
    enum GraphUplink:Sendable
    {
        case coordinate(Int32, Int32)
        case identifier(VolumeIdentifier)
    }
}
extension Server.Endpoint.GraphUplink:ProceduralEndpoint
{
    func perform(on server:Server, with _:[UInt8]) async throws -> HTTP.ServerResponse
    {
        let session:Mongo.Session = try await .init(from: server.db.sessions)
        let updated:UnidocDatabase.Uplinked? = switch self
        {
        case .coordinate(let package, let version):
            try await server.db.unidoc.uplink(
                package: package,
                version: version,
                with: session)

        case .identifier(let volume):
            try await server.db.unidoc.uplink(volume: volume, with: session)
        }

        guard
        let updated:UnidocDatabase.Uplinked
        else
        {
            return .notFound("No such symbol graph.")
        }

        if  let pages:Realm.Sitemap.Delta = updated.sitemap
        {
            Log[.debug] = """
            Sitemap (\(updated.edition.package)) lost \(pages.deletions.count) pages \
            and gained \(pages.additions) pages.
            """
        }

        if  try await server.db.unidoc.docsFeed.push(.init(
                    discovered: .now(),
                    volume: updated.edition),
                with: session)
        {
            return .ok("Uplink successful, documentation feed updated.")
        }
        else
        {
            return .ok("Uplink successful, documentation feed not updated.")
        }
    }
}
