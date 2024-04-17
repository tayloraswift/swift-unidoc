import GitHubAPI
import GitHubClient
import HTTP
import MongoDB
import Multiparts
import SwiftinitPages
import SymbolGraphs
import UnidocDB

extension Unidoc
{
    enum SiteConfigOperation
    {
        case perform(Unidoc.AdminPage.Action, MultipartForm?)
        case recode(Unidoc.AdminPage.Recode.Target)
        case telescope(days:Int)
    }
}
extension Unidoc.SiteConfigOperation:Unidoc.AdministrativeOperation
{
    func load(from server:borrowing Unidoc.Server,
        with session:Mongo.Session) async throws -> HTTP.ServerResponse?
    {
        let page:Unidoc.AdminPage.Action.Complete

        switch self
        {
        case .recode(let target):
            let collection:any Mongo.RecodableModel

            switch target
            {
            case .packages:    collection = server.db.packages
            case .editions:    collection = server.db.editions
            case .vertices:    collection = server.db.vertices
            case .volumes:     collection = server.db.volumes
            }

            let (modified, selected):(Int, Int) = try await collection.recode(with: session)
            let complete:Unidoc.AdminPage.Recode.Complete = .init(
                selected: selected,
                modified: modified,
                target: target)

            return .ok(complete.resource(format: server.format))

        case .perform(.dropUnidocDB, _):
            try await server.db.unidoc.drop(with: session)

            page = .init(action: .dropUnidocDB, text: "Reinitialized Unidoc database!")

        case .perform(.restart, _):
            fatalError("Restarting server...")

        case .perform(.upload, _):
            //  No longer supported.
            return nil

        case .telescope(days: let days):
            let updates:Mongo.Updates = try await server.db.crawlingWindows.create(days: days,
                with: session)

            return .ok("Updated \(updates.modified) of \(updates.selected) crawling windows.")
        }

        return .ok(page.resource(format: server.format))
    }
}
