import HTTPServer
import MongoDB
import Multiparts
import SymbolGraphs
import UnidocDatabase
import UnidocPages

extension Server.Endpoint
{
    enum Admin
    {
        case perform(Site.Action, MultipartForm?)
        case status
    }
}
extension Server.Endpoint.Admin:DatabaseOperation
{
    func load(from database:Services.Database) async throws -> ServerResponse?
    {
        let session:Mongo.Session = try await .init(from: database.sessions)
        let page:Site.Action.Receipt

        switch self
        {
        case .status:
            let page:Site.Admin = .init(configuration: try await database.sessions.run(
                command: Mongo.ReplicaSetGetConfiguration.init(),
                against: .admin))

            return .resource(page.rendered())

        case .perform(.dropDatabase, _):
            try await database.unidoc.nuke(with: session)

            page = .init(action: .dropDatabase, text: "Reinitialized database!")

        case .perform(.rebuild, _):
            let rebuilt:Int = try await database.unidoc.rebuild(with: session)

            page = .init(action: .rebuild, text: "Rebuilt \(rebuilt) snapshots!")

        case .perform(.upload, let form?):
            var receipts:[SnapshotReceipt] = []

            for item:MultipartForm.Item in form
                where item.header.name == "documentation-binary"
            {
                receipts.append(try await database.unidoc.publish(
                    docs: try .init(buffer: item.value),
                    with: session))
            }

            page = .init(action: .upload, text: "\(receipts)")

        case .perform(.upload, nil):
            return nil
        }

        return .resource(page.rendered())
    }
}
