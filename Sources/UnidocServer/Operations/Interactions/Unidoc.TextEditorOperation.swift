import HTTP
import MongoDB
import UnidocUI

extension Unidoc {
    /// Allows editing the `robots.txt` file.
    struct TextEditorOperation: Sendable {
        let id: Unidoc.DB.Metadata.Key

        init(id: Unidoc.DB.Metadata.Key) {
            self.id = id
        }
    }
}
extension Unidoc.TextEditorOperation: Unidoc.AdministrativeOperation {
    func load(
        from server: Unidoc.Server,
        db: Unidoc.DB,
        as format: Unidoc.RenderFormat
    ) async throws -> HTTP.ServerResponse? {
        let action: Unidoc.PostAction
        switch self.id {
        case .robots_txt:
            action = .robots_txt

        default:
            return nil
        }

        let text: Unidoc.TextResource<Unidoc.DB.Metadata.Key>? =
        try await db.metadata.find(id: .robots_txt)

        let page: Unidoc.TextEditorPage = .init(
            string: try text.map {
                String.init(decoding: try $0.text.utf8(), as: UTF8.self)
            } ?? "",
            action: action
        )

        return .ok(page.resource(format: format))
    }
}
