import HTTP
import MongoDB
import Multiparts

extension Unidoc
{
    /// Allows editing the `robots.txt` file.
    struct TextUpdateOperation:Sendable
    {
        let text:Unidoc.TextResource<Unidoc.DB.Metadata.Key>

        init(text:Unidoc.TextResource<Unidoc.DB.Metadata.Key>)
        {
            self.text = text
        }
    }
}
extension Unidoc.TextUpdateOperation:Unidoc.AdministrativeOperation
{
    func load(from server:Unidoc.Server,
        with session:Mongo.Session) async throws -> HTTP.ServerResponse?
    {
        let _:Bool? = try await server.db.metadata.update(with: session)
        {
            $0.upsert(self.text)
        }

        return .redirect(.seeOther("/robots.txt"))
    }
}
