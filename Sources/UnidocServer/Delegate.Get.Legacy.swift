import HTML
import HTTPServer
import MongoDB
import UnidocDatabase
import UnidocQueries
import UnidocRecords
import URI

extension Delegate.Get
{
    struct Legacy:Sendable
    {
        let query:DeepQuery

        init(query:DeepQuery)
        {
            self.query = query
        }
    }
}
extension Delegate.Get.Legacy
{
    func load(from database:Database, pool:Mongo.SessionPool) async throws -> ServerResponse?
    {
        let session:Mongo.Session = try await .init(from: pool)
        let output:[DeepQuery.Output] = try await database.execute(
            query: self.query,
            with: session)

        guard output.count == 1, output[0].principal.count == 1
        else
        {
            return nil
        }

        let principal:DeepQuery.Output.Principal = output[0].principal[0]
        let location:URI
        switch principal.master ?? principal.matches.first
        {
        case .article(let master)?: location = .init(article: master, in: principal.zone)
        case .culture(let master)?: location = .init(culture: master, in: principal.zone)
        case .decl(let master)?:    location = .init(decl: master, in: principal.zone,
            disambiguate: principal.master != nil)
        case .file?, nil:           return nil
        }

        return .redirect(.permanent("\(location)"))
    }
}
