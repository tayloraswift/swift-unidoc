import HTTP
import MD5
import MongoDB
import UnidocDB
import UnidocPages
import URI

extension Server.Operation
{
    struct Pipeline<Query>:Sendable
        where   Query:DatabaseQuery,
                Query.Output:ServerResponseFactory<URI>
    {
        let database:@Sendable (_ among:Server.DB) -> Query.Database
        let explain:Bool
        let query:Query
        let uri:URI
        let tag:MD5?

        private
        init(
            database:@Sendable @escaping (Server.DB) -> Query.Database,
            explain:Bool,
            query:Query,
            uri:URI,
            tag:MD5?)
        {
            self.database = database
            self.explain = explain
            self.query = query
            self.uri = uri
            self.tag = tag
        }
    }
}
extension Server.Operation.Pipeline where Query.Database == UnidocDatabase
{
    init(explain:Bool, query:Query, uri:URI, tag:MD5? = nil)
    {
        self.init(database: \.unidoc,
            explain: explain,
            query: query,
            uri: uri,
            tag: tag)
    }
}
extension Server.Operation.Pipeline where Query.Database == PackageDatabase
{
    init(explain:Bool, query:Query, uri:URI, tag:MD5? = nil)
    {
        self.init(database: \.package,
            explain: explain,
            query: query,
            uri: uri,
            tag: tag)
    }
}
extension Server.Operation.Pipeline:InteractiveOperation
{
    var statisticalType:WritableKeyPath<ServerTour.Stats.ByType, Int>
    {
        \.query
    }
}
extension Server.Operation.Pipeline:UnrestrictedOperation
{
    func load(from server:Server.State) async throws -> ServerResponse?
    {
        try await self.load(
            from: self.database(server.db),
            with: try await .init(from: server.db.sessions))
    }

    private
    func load(from db:Query.Database,
        with session:Mongo.Session) async throws -> ServerResponse?
    {
        if  self.explain
        {
            let explanation:String = try await db.explain(
                query: self.query,
                with: session)

            return .resource(.init(.one(canonical: nil),
                content: .string(explanation),
                type: .text(.plain, charset: .utf8)))
        }

        guard
        let output:Query.Output = try await db.execute(query: self.query, with: session)
        else
        {
            return nil
        }

        switch try output.response(for: self.uri)
        {
        case .redirect(let redirect, cookies: let cookies):
            return .redirect(redirect, cookies: cookies)

        case .resource(var resource):
            resource.optimize(tag: self.tag)
            return .resource(resource)
        }
    }
}
