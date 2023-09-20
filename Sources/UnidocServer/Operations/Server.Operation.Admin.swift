import GitHubClient
import GitHubAPI
import HTTP
import MongoDB
import Multiparts
import SymbolGraphs
import UnidocDB
import UnidocPages

extension Server.Operation
{
    enum Admin
    {
        case perform(Site.Admin.Action, MultipartForm?)
    }
}
extension Server.Operation.Admin:RestrictedOperation
{
    func load(from server:Server.State) async throws -> ServerResponse?
    {
        let session:Mongo.Session = try await .init(from: server.db.sessions)
        let page:Site.Admin.Receipt

        switch self
        {
        case .perform(.dropAccountDB, _):
            try await server.db.account.drop(with: session)

            page = .init(action: .dropAccountDB, text: "Reinitialized Account database!")

        case .perform(.dropPackageDB, _):
            try await server.db.package.drop(with: session)

            page = .init(action: .dropPackageDB, text: "Reinitialized Package database!")

        case .perform(.dropUnidocDB, _):
            try await server.db.unidoc.drop(with: session)

            page = .init(action: .dropUnidocDB, text: "Reinitialized Unidoc database!")

        case .perform(.lintPackageEditions, _):
            let deleted:Int = try await server.db.package.editions._lint(with: session)

            page = .init(action: .lintPackageEditions,
                text: "Deleted \(deleted) editions!")

        case .perform(.recodePackageEditions, _):
            let (modified, total):(Int, Int) = try await server.db.package.editions.recode(
                with: session)

            page = .init(action: .recodePackageEditions,
                text: "Modified \(modified) of \(total) editions!")

        case .perform(.recodePackageRecords, _):
            let (modified, total):(Int, Int) = try await server.db.package.packages.recode(
                with: session)

            page = .init(action: .recodePackageRecords,
                text: "Modified \(modified) of \(total) packages!")

        case .perform(.recodeUnidocVertices, _):
            let (modified, total):(Int, Int) = try await server.db.unidoc.vertices.recode(
                with: session)

            page = .init(action: .recodeUnidocVertices,
                text: "Modified \(modified) of \(total) vertices!")

        case .perform(.rebuild, _):
            let rebuilt:Int = try await server.db.unidoc.rebuild(
                from: server.db.package,
                with: session)

            page = .init(action: .rebuild, text: "Rebuilt \(rebuilt) snapshots!")

        case .perform(.upload, let form?):
            var receipts:[SnapshotReceipt] = []

            for item:MultipartForm.Item in form
                where item.header.name == "documentation-binary"
            {
                let documentation:SymbolGraphArchive = try .init(buffer: item.value)
                let receipt:SnapshotReceipt = try await server.db.unidoc.publish(
                    linking: documentation,
                    against: server.db.package,
                    with: session)

                receipts.append(receipt)
            }

            page = .init(action: .upload, text: "\(receipts)")

        case .perform(.upload, nil):
            return nil
        }

        return .resource(page.rendered())
    }
}
