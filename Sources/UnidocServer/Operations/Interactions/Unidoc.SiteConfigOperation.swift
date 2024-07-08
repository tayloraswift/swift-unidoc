import GitHubAPI
import GitHubClient
import HTTP
import MongoDB
import Multiparts
import SymbolGraphs
import UnidocDB
import UnidocUI
import UnixTime

extension Unidoc
{
    enum SiteConfigOperation
    {
        case recode(Unidoc._RecodePage.Target)
        case telescope(last:Days)
    }
}
extension Unidoc.SiteConfigOperation:Unidoc.AdministrativeOperation
{
    func load(from server:Unidoc.Server,
        with session:Mongo.Session,
        as format:Unidoc.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        switch self
        {
        case .recode(let target):
            let collection:any Mongo.RecodableModel

            switch target
            {
            case .packageDependencies:  collection = server.db.packageDependencies
            case .packages:             collection = server.db.packages
            case .editions:             collection = server.db.editions
            case .vertices:             collection = server.db.vertices
            case .volumes:              collection = server.db.volumes
            }

            let (modified, selected):(Int, Int) = try await collection.recode(with: session)
            let complete:Unidoc._RecodePage.Complete = .init(
                selected: selected,
                modified: modified,
                target: target)

            return .ok(complete.resource(format: format))

        case .telescope(last: let days):
            let updates:Mongo.Updates = try await server.db.crawlingWindows.create(
                previous: days,
                with: session)

            return .ok("Updated \(updates.modified) of \(updates.selected) crawling windows.")
        }
    }
}
