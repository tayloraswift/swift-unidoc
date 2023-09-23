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
        case recode(Site.Admin.Recode)
    }
}
extension Server.Operation.Admin:RestrictedOperation
{
    func load(from server:Server.State) async throws -> ServerResponse?
    {
        let session:Mongo.Session = try await .init(from: server.db.sessions)
        let page:Site.Admin.Action.Complete

        switch self
        {
        case .recode(let recode):
            let target:any RecodableCollection

            switch recode.target
            {
            case .packages:    target = server.db.unidoc.packages
            case .editions:    target = server.db.unidoc.editions
            case .vertices:    target = server.db.unidoc.vertices
            case .names:       target = server.db.unidoc.names
            }

            let (modified, selected):(Int, Int) = try await target.recode(with: session)
            let complete:Site.Admin.Recode.Complete = .init(
                selected: selected,
                modified: modified,
                target: recode.target)

            return .resource(complete.rendered())

        case .perform(.dropAccountDB, _):
            try await server.db.account.drop(with: session)

            page = .init(action: .dropAccountDB, text: "Reinitialized Account database!")

        case .perform(.dropUnidocDB, _):
            try await server.db.unidoc.drop(with: session)

            page = .init(action: .dropUnidocDB, text: "Reinitialized Unidoc database!")

        case .perform(.lintUnidocEditions, _):
            let deleted:Int = try await server.db.unidoc.editions._lint(with: session)

            page = .init(action: .lintUnidocEditions,
                text: "Deleted \(deleted) editions!")

        case .perform(.rebuild, _):
            let rebuilt:Int = try await server.db.unidoc._rebuild(with: session)

            page = .init(action: .rebuild, text: "Rebuilt \(rebuilt) snapshots!")

        case .perform(.upload, let form?):
            var receipts:[SnapshotReceipt] = []

            for item:MultipartForm.Item in form
                where item.header.name == "documentation-binary"
            {
                let documentation:SymbolGraphArchive = try .init(buffer: item.value)
                let receipt:SnapshotReceipt = try await server.db.unidoc.publish(
                    linking: documentation,
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
