import GitHubAPI
import GitHubClient
import HTTP
import MongoDB
import Multiparts
import SymbolGraphs
import UnidocDB
import UnidocUI
import UnixTime

extension Unidoc {
    enum SiteConfigOperation {
        case recode(Unidoc._RecodePage.Target)
        case telescope(last: Days)
    }
}
extension Unidoc.SiteConfigOperation: Unidoc.AdministrativeOperation {
    func load(
        from server: Unidoc.Server,
        db: Unidoc.DB,
        as format: Unidoc.RenderFormat
    ) async throws -> HTTP.ServerResponse? {
        switch self {
        case .recode(let target):
            let collection: any Mongo.RecodableModel

            switch target {
            case .packageDependencies:  collection = db.packageDependencies
            case .packages:             collection = db.packages
            case .editions:             collection = db.editions
            case .volumes:              collection = db.volumes
            }

            let (modified, selected): (Int, Int) = try await collection.recode(
                stride: 4096,
                by: .now.advanced(by: .seconds(60))
            )
            let complete: Unidoc._RecodePage.Complete = .init(
                selected: selected,
                modified: modified,
                target: target
            )

            return .ok(complete.resource(format: format))

        case .telescope(last: let days):
            let updates: Mongo.Updates = try await db.crawlingWindows.create(
                previous: days
            )

            return .ok("Updated \(updates.modified) of \(updates.selected) crawling windows.")
        }
    }
}
