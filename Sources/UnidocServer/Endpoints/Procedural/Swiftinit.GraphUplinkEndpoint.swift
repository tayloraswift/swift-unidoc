import HTTP
import HTTPServer
import MongoDB
import Unidoc
import UnidocDB
import UnidocRecords

extension Swiftinit
{
    enum GraphUplinkEndpoint:Sendable
    {
        case coordinate(Unidoc.Edition)
        case identifier(VolumeIdentifier)
    }
}
extension Swiftinit.GraphUplinkEndpoint:BlockingEndpoint
{
    func perform(on server:borrowing Swiftinit.Server,
        payload _:consuming [UInt8],
        session:Mongo.Session) async throws -> HTTP.ServerResponse
    {
        let updated:UnidocDatabase.Uplinked?

        switch self
        {
        case .coordinate(let edition):
            updated = try await server.db.unidoc.uplink(edition, with: session)

        case .identifier(let volume):
            updated = try await server.db.unidoc.uplink(volume: volume, with: session)
        }

        guard
        let updated:UnidocDatabase.Uplinked
        else
        {
            return .notFound("No such symbol graph.")
        }

        if  let pages:Unidoc.Sitemap.Delta = updated.sitemap
        {
            Log[.debug] = """
            Sitemap (\(updated.edition.package)) lost \(pages.deletions.count) pages \
            and gained \(pages.additions) pages.
            """
        }

        guard updated.visibleInFeed
        else
        {
            return .ok("Uplink successful, repo is invisible.")
        }

        if  try await server.db.docsFeed.push(.init(
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
