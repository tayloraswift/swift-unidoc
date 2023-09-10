import GitHubClient
import GitHubIntegration
import HTTP
import MongoDB
import Multiparts
import SymbolGraphs
import UnidocDatabase
import UnidocPages

extension Server.Endpoint
{
    enum Admin
    {
        case perform(Site.Admin.Action, MultipartForm?)
        case status
    }
}
extension Server.Endpoint.Admin:RestrictedOperation
{
    func load(from services:Services) async throws -> ServerResponse?
    {
        let session:Mongo.Session = try await .init(from: services.database.sessions)
        let page:Site.Admin.Receipt

        switch self
        {
        case .status:
            let page:Site.Admin = .init(configuration: try await services.database.sessions.run(
                    command: Mongo.ReplicaSetGetConfiguration.init(),
                    against: .admin),
                tour: services.tour,
                real: services.mode == .secured)

            return .resource(page.rendered())

        case .perform(.dropAccountDB, _):
            try await services.database.account.drop(with: session)

            page = .init(action: .dropAccountDB, text: "Reinitialized Account database!")

        case .perform(.dropPackageDB, _):
            try await services.database.package.drop(with: session)

            page = .init(action: .dropPackageDB, text: "Reinitialized Package database!")

        case .perform(.dropUnidocDB, _):
            try await services.database.unidoc.drop(with: session)

            page = .init(action: .dropUnidocDB, text: "Reinitialized Unidoc database!")

        case .perform(.rebuild, _):
            let rebuilt:Int = try await services.database.unidoc.rebuild(
                from: services.database.package,
                with: session)

            page = .init(action: .rebuild, text: "Rebuilt \(rebuilt) snapshots!")

        case .perform(.upload, let form?):
            var receipts:[SnapshotReceipt] = []

            for item:MultipartForm.Item in form
                where item.header.name == "documentation-binary"
            {
                let documentation:SymbolGraphArchive = try .init(buffer: item.value)
                let receipt:SnapshotReceipt = try await services.database.unidoc.publish(
                    linking: documentation,
                    against: services.database.package,
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
