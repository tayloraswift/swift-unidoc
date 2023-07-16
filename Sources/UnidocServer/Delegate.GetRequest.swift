import HTML
import HTTPServer
import MongoDB
import NIOCore
import NIOHTTP1
import UnidocDatabase
import URI

extension Delegate
{
    struct GetRequest:Sendable
    {
        let promise:EventLoopPromise<ServerResource>
        let uri:URI

        init(promise:EventLoopPromise<ServerResource>, uri:URI)
        {
            self.promise = promise
            self.uri = uri
        }
    }
}
extension Delegate.GetRequest:ServerDelegateGetRequest
{
    init?(_ uri:String,
        address _:SocketAddress?,
        headers _:HTTPHeaders,
        with promise:() -> EventLoopPromise<ServerResource>)
    {
        if  let uri:URI = .init(uri)
        {
            self.init(promise: promise(), uri: uri)
        }
        else
        {
            return nil
        }
    }
}
extension Delegate.GetRequest
{
    func respond(using database:Database,
        in pool:Mongo.SessionPool) async throws -> ServerResource?
    {
        let parameters:Parameters = .init(uri.query)
        let path:[String] = uri.path.normalized(lowercase: true)

        switch path
        {
        case ["admin"]:
            let page:Site.AdminPage = .init(configuration: try await pool.run(
                command: Mongo.ReplicaSetGetConfiguration.init(),
                against: .admin))

            let html:HTML = .document { $0[.html] { $0.lang = "en" } = page }

            return .init(location: "\(self.uri)",
                response: .content(.init(.binary(html.utf8),
                    type: .text(.html, charset: .utf8))),
                results: .one(canonical: "/admin"))

        case ["admin", "drop-database"]:
            let page:Site.AdminPage.DropDatabase = .init()
            let html:HTML = .document { $0[.html] { $0.lang = "en" } = page }

            return .init(location: "\(self.uri)",
                response: .content(.init(.binary(html.utf8),
                    type: .text(.html, charset: .utf8))),
                results: .one(canonical: "/admin/drop-database"))

        case _:
            if  path.count < 2
            {
                return nil
            }

            let query:DeepQuery?

            switch path[0]
            {
            case "docs":
                query = .init(.docs, path[1], path[2...], hash: parameters.hash)

            case "learn":
                query = .init(.learn, path[1], path[2...], hash: parameters.hash)

            case _:
                return nil
            }

            guard let query:DeepQuery
            else
            {
                return nil
            }

            let session:Mongo.Session = try await .init(from: pool)

            if  parameters.explain
            {
                let explanation:String = try await database.explain(
                    query: query,
                    with: session)

                let location:String = "\(self.uri)"

                return .init(location: location,
                    response: .content(.init(.text(explanation),
                        type: .text(.plain, charset: .utf8))),
                    results: .one(canonical: location))
            }
            else if
                let page:Site.Docs.DeepPage = .init(try await database.execute(
                    query: query,
                    with: session))
            {
                let html:HTML = .document { $0[.html] { $0.lang = "en" } = page }
                let location:String = "\(page.location)"

                return .init(location: location,
                    response: .content(.init(.binary(html.utf8),
                        type: .text(.html, charset: .utf8))),
                    results: .one(canonical: location))
            }
            else
            {
                return nil
            }
        }
    }
}
