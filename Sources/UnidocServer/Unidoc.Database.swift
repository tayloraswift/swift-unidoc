import MongoDB
import UnidocDB
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct Database:Sendable
    {
        public
        let sessions:Mongo.SessionPool
        public
        let unidoc:Mongo.Database
        public
        let policy:SecurityPolicy

        @inlinable public
        init(sessions:Mongo.SessionPool, unidoc:Mongo.Database, policy:SecurityPolicy)
        {
            self.sessions = sessions
            self.unidoc = unidoc
            self.policy = policy
        }
    }
}
extension Unidoc.Database
{
    @inlinable
    func session() async throws -> Unidoc.DB
    {
        let session:Mongo.Session = try await .init(from: self.sessions)
        return .init(session: session, in: self.unidoc, policy: self.policy)
    }
}
