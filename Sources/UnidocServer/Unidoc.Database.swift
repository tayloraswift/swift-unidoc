import MongoDB
import UnidocDB
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct Database:Sendable
    {
        public
        let settings:DatabaseSettings
        public
        let sessions:Mongo.SessionPool
        public
        let unidoc:Mongo.Database

        @inlinable public
        init(settings:DatabaseSettings, sessions:Mongo.SessionPool, unidoc:Mongo.Database)
        {
            self.settings = settings
            self.sessions = sessions
            self.unidoc = unidoc
        }
    }
}
extension Unidoc.Database
{
    @inlinable public
    func session() async throws -> Unidoc.DB
    {
        let session:Mongo.Session = try await .init(from: self.sessions)
        return .init(session: session, in: self.unidoc, settings: self.settings)
    }
}
