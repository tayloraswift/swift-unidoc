import HTTP
import MD5
import MongoDB
import UnidocDatabase
import UnidocPages
import URI

extension Server.Endpoint
{
    struct Pipeline<Database, Query>:Sendable
        where   Database:DatabaseModel,
                Query:DatabaseQuery,
                Query.Output:ServerResponseFactory<URI>
    {
        let database:@Sendable (_ among:Services.Database) -> Database
        let explain:Bool
        let query:Query
        let uri:URI
        let tag:MD5?

        private
        init(
            database:@Sendable @escaping (Services.Database) -> Database,
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
extension Server.Endpoint.Pipeline where Database == UnidocDatabase
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
extension Server.Endpoint.Pipeline where Database == PackageDatabase
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
extension Server.Endpoint.Pipeline:StatefulOperation
{
    var statisticalType:WritableKeyPath<ServerTour.Stats.ByType, Int>
    {
        \.query
    }
}
extension Server.Endpoint.Pipeline:DatabaseOperation, UnrestrictedOperation
{
    func load(from database:Services.Database) async throws -> ServerResponse?
    {
        try await self.load(
            from: self.database(database),
            with: try await .init(from: database.sessions))
    }

    private
    func load(from database:Database,
        with session:Mongo.Session) async throws -> ServerResponse?
    {
        if  self.explain
        {
            let explanation:String = try await database.explain(
                query: self.query,
                with: session)

            return .resource(.init(.one(canonical: nil),
                content: .string(explanation),
                type: .text(.plain, charset: .utf8)))
        }

        guard   let output:Query.Output = try await database.execute(
                    query: self.query,
                    with: session)
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
