import HTTPServer
import MongoDB
import UnidocDatabase

protocol DatabaseOperation:Sendable
{
    func load(from database:Unidoc.Database,
        pool:Mongo.SessionPool) async throws -> ServerResponse?
}
