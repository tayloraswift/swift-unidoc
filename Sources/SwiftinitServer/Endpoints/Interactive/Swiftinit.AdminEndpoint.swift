import GitHubAPI
import GitHubClient
import HTTP
import MongoDB
import Multiparts
import SwiftinitPages
import SymbolGraphs
import UnidocDB

extension Swiftinit
{
    enum AdminEndpoint
    {
        case perform(Swiftinit.AdminPage.Action, MultipartForm?)
        case recode(Swiftinit.AdminPage.Recode.Target)
        case telescope(days:Int)
    }
}
extension Swiftinit.AdminEndpoint:RestrictedEndpoint
{
    func load(from server:borrowing Swiftinit.Server) async throws -> HTTP.ServerResponse?
    {
        let session:Mongo.Session = try await .init(from: server.db.sessions)
        let page:Swiftinit.AdminPage.Action.Complete

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
            let complete:Swiftinit.AdminPage.Recode.Complete = .init(
                selected: selected,
                modified: modified,
                target: target)

            return .ok(complete.resource(format: server.format))

        case .perform(.dropUnidocDB, _):
            try await server.db.unidoc.drop(with: session)

            page = .init(action: .dropUnidocDB, text: "Reinitialized Unidoc database!")

        case .perform(.restart, _):
            fatalError("Restarting server...")

        case .perform(.upload, let form?):
            var receipts:[Unidoc.UploadStatus] = []

            for item:MultipartForm.Item in form
                where item.header.name == "documentation-binary"
            {
                let archive:SymbolGraphArchive = try .init(buffer: item.value)
                let receipt:Unidoc.UploadStatus = try await server.db.unidoc.publish(
                    docs: archive,
                    with: session).0

                receipts.append(receipt)
            }

            page = .init(action: .upload, text: "\(receipts)")

        case .perform(.upload, nil):
            return nil

        case .telescope(days: let days):
            let updates:Mongo.Updates = try await server.db.crawlingWindows.create(days: days,
                with: session)

            return .ok("Updated \(updates.modified) of \(updates.selected) crawling windows.")
        }

        return .ok(page.resource(format: server.format))
    }
}
