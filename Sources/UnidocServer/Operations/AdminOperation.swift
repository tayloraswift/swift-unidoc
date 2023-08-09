import HTTPServer
import MongoDB
import Multiparts
import SymbolGraphs
import UnidocDatabase
import UnidocPages

enum AdminOperation
{
    case perform(Site.Action, MultipartForm?)
    case status
}
extension AdminOperation:DatabaseOperation
{
    func load(from database:Database, pool:Mongo.SessionPool) async throws -> ServerResponse?
    {
        let session:Mongo.Session = try await .init(from: pool)
        let page:Site.Action.Receipt

        switch self
        {
        case .status:
            let page:Site.Admin = .init(configuration: try await pool.run(
                command: Mongo.ReplicaSetGetConfiguration.init(),
                against: .admin))

            return .resource(page.rendered())

        case .perform(.dropDatabase, _):
            try await database.nuke(with: session)

            page = .init(action: .dropDatabase, text: "Reinitialized database!")

        case .perform(.rebuild, _):
            let rebuilt:Int = try await database.rebuild(with: session)

            page = .init(action: .rebuild, text: "Rebuilt \(rebuilt) snapshots!")

        case .perform(.upload, let form?):
            var receipts:[SnapshotReceipt] = []

            for item:MultipartForm.Item in form
                where item.header.name == "documentation-binary"
            {
                receipts.append(try await database.publish(
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
