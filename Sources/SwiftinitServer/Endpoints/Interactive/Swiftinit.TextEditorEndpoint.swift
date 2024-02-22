import HTTP
import MongoDB

extension Swiftinit
{
    /// Allows editing the `robots.txt` file.
    struct TextEditorEndpoint:Sendable
    {
        let id:Unidoc.DB.Metadata.Key

        init(id:Unidoc.DB.Metadata.Key)
        {
            self.id = id
        }
    }
}
extension Swiftinit.TextEditorEndpoint:RestrictedEndpoint
{
    func load(from server:borrowing Swiftinit.Server) async throws -> HTTP.ServerResponse?
    {
        let action:Swiftinit.API.Post
        switch self.id
        {
        case .robots_txt:
            action = .robots_txt

        default:
            return nil
        }

        let session:Mongo.Session = try await .init(from: server.db.sessions)

        let text:Unidoc.TextResource<Unidoc.DB.Metadata.Key>? =
            try await server.db.metadata.find(id: .robots_txt, with: session)

        let page:Swiftinit.TextEditorPage = .init(
            string: try text.map
            {
                String.init(decoding: try $0.text.utf8(), as: UTF8.self)
            } ?? "",
            action: action)

        return .ok(page.resource(format: server.format))
    }
}
