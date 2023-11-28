import GitHubClient
import GitHubAPI
import HTTP
import MongoDB
import Multiparts
import SymbolGraphs
import UnidocDB
import UnidocPages

extension Server.Endpoint
{
    enum Admin
    {
        case perform(Site.Admin.Action, MultipartForm?)
        case recode(Site.Admin.Recode.Target)
    }
}
extension Server.Endpoint.Admin:RestrictedEndpoint
{
    func load(from server:Server) async throws -> HTTP.ServerResponse?
    {
        let session:Mongo.Session = try await .init(from: server.db.sessions)
        let page:Site.Admin.Action.Complete

        switch self
        {
        case .recode(let target):
            let collection:any Mongo.RecodableModel

            switch target
            {
            case .packages:    collection = server.db.unidoc.packages
            case .editions:    collection = server.db.unidoc.editions
            case .vertices:    collection = server.db.unidoc.vertices
            case .volumes:     collection = server.db.unidoc.volumes
            }

            let (modified, selected):(Int, Int) = try await collection.recode(with: session)
            let complete:Site.Admin.Recode.Complete = .init(
                selected: selected,
                modified: modified,
                target: target)

            return .ok(complete.resource(assets: server.assets))

        case .perform(.dropAccountDB, _):
            try await server.db.account.drop(with: session)

            page = .init(action: .dropAccountDB, text: "Reinitialized Account database!")

        case .perform(.dropUnidocDB, _):
            try await server.db.unidoc.drop(with: session)

            page = .init(action: .dropUnidocDB, text: "Reinitialized Unidoc database!")

        case .perform(.restart, _):
            fatalError("Restarting server...")

        case .perform(.upload, let form?):
            var receipts:[UnidocDatabase.Uploaded] = []

            for item:MultipartForm.Item in form
                where item.header.name == "documentation-binary"
            {
                let archive:SymbolGraphArchive = try .init(buffer: item.value)
                let receipt:UnidocDatabase.Uploaded = try await server.db.unidoc.publish(
                    docs: archive,
                    with: session).0

                receipts.append(receipt)
            }

            page = .init(action: .upload, text: "\(receipts)")

        case .perform(.upload, nil):
            return nil
        }

        return .ok(page.resource(assets: server.assets))
    }
}
