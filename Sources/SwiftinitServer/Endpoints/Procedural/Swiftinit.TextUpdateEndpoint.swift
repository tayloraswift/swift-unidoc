import HTTP
import MongoDB
import Multiparts

extension Swiftinit
{
    /// Allows editing the `robots.txt` file.
    struct TextUpdateEndpoint:Sendable
    {
        let text:Unidoc.TextResource<Unidoc.DB.Metadata.Key>

        init(text:Unidoc.TextResource<Unidoc.DB.Metadata.Key>)
        {
            self.text = text
        }
    }
}
extension Swiftinit.TextUpdateEndpoint:BlockingEndpoint
{
    func perform(on server:borrowing Swiftinit.Server,
        payload:consuming [UInt8],
        session:Mongo.Session) async throws -> HTTP.ServerResponse
    {
        let _:Bool? = try await server.db.metadata.update(with: session)
        {
            $0.upsert(self.text)
        }

        return .redirect(.seeOther("/robots.txt"))
    }
}
