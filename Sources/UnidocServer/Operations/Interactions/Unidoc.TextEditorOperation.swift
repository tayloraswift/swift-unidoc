import HTTP
import UnidocUI
import MongoDB

extension Unidoc
{
    /// Allows editing the `robots.txt` file.
    struct TextEditorOperation:Sendable
    {
        let id:Unidoc.DB.Metadata.Key

        init(id:Unidoc.DB.Metadata.Key)
        {
            self.id = id
        }
    }
}
extension Unidoc.TextEditorOperation:Unidoc.AdministrativeOperation
{
    func load(from server:borrowing Unidoc.Server,
        with session:Mongo.Session) async throws -> HTTP.ServerResponse?
    {
        let action:Unidoc.PostAction
        switch self.id
        {
        case .robots_txt:
            action = .robots_txt

        default:
            return nil
        }

        let text:Unidoc.TextResource<Unidoc.DB.Metadata.Key>? =
            try await server.db.metadata.find(id: .robots_txt, with: session)

        let page:Unidoc.TextEditorPage = .init(
            string: try text.map
            {
                String.init(decoding: try $0.text.utf8(), as: UTF8.self)
            } ?? "",
            action: action)

        return .ok(page.resource(format: server.format))
    }
}
