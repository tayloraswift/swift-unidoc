import GitHubClient
import GitHubIntegration
import HTTPClient
import HTTPServer
import MongoDB
import NIOCore
import NIOPosix
import NIOHTTP1
import NIOSSL
import System
import UnidocDatabase
import UnidocPages

final
actor Server
{
    private nonisolated
    let requests:(in:AsyncStream<Request>.Continuation, out:AsyncStream<Request>)

    private nonisolated
    let database:Unidoc.Database
    private nonisolated
    let mongodb:Mongo.SessionPool

    private nonisolated
    let cache:Cache<Site.Asset>

    private
    init(database:Unidoc.Database, mongodb:Mongo.SessionPool, reload:Bool)
    {
        var continuation:AsyncStream<Request>.Continuation? = nil
        self.requests.out = .init
        {
            continuation = $0
        }
        self.requests.in = continuation!

        self.database = database
        self.mongodb = mongodb

        self.cache = .init(source: "Assets", reload: reload)
    }
}
extension Server
{
    func respond(on threads:MultiThreadedEventLoopGroup) async throws
    {
        //  This is a client context, which is different from the server context.
        let niossl:NIOSSLContext = try .init(configuration: .makeClientConfiguration())
        let github:(oauth:GitHubClient<GitHubOAuth>, app:GitHubClient<GitHubApp>)?

        if  let secret:(oauth:String, app:String) = try?
            (
                (self.cache.assets / "secrets" / "github-oauth-secret").read(),
                (self.cache.assets / "secrets" / "github-app-secret").read()
            )
        {
            func trim(_ string:String) -> String
            {
                .init(string.prefix(while: \.isHexDigit))
            }

            let http2:HTTP2Client = .init(threads: threads,
                niossl: niossl,
                remote: "github.com")

            github =
            (
                oauth: .init(http2: http2, app: .init(
                    client: "2378cacaed3ace362867",
                    secret: trim(secret.oauth))),

                app: .init(http2: http2, app: .init(383005,
                    client: "Iv1.dba609d35c70bf57",
                    secret: trim(secret.app)))
            )
        }
        else
        {
            print("Note: App secret unavailable, GitHub integration has been disabled!")
            github = nil
        }

        for await request:Request in self.requests.out
        {
            try Task.checkCancellation()

            let response:ServerResponse?
            do
            {
                switch request.operation
                {
                case .github(let operation):
                    if  let github:GitHubClient<GitHubOAuth> = github?.oauth
                    {
                        response = try await operation.load(from: github,
                            into: self.database,
                            pool: self.mongodb,
                            with: request.cookies)
                    }
                    else
                    {
                        response = nil
                    }

                case .database(let operation):
                    response = try await operation.load(from: self.database,
                        pool: self.mongodb)

                case .load(let operation):
                    response = try await operation.load(from: self.cache)

                case .none(let stateless):
                    response = stateless
                }
            }
            catch let error
            {
                request.promise.fail(error)
                continue
            }

            if  let response:ServerResponse
            {
                request.promise.succeed(response)
            }
            else
            {
                request.promise.succeed(.resource(.init(.none,
                    content: .string("not found"),
                    type: .text(.plain, charset: .utf8))))
            }
        }
    }
}
extension Server:ServerDelegate
{
    nonisolated
    func yield(_ request:Request)
    {
        switch self.requests.in.yield(request)
        {
        case .enqueued: return
        case _:         fatalError("unimplemented")
        }
    }
}

@main
extension Server
{
    public static
    func main() async throws
    {
        let threads:MultiThreadedEventLoopGroup = .init(numberOfThreads: 2)
        let options:Options = try .parse()
        if  options.redirect
        {
            try await options.authority.type.redirect(from: ("0.0.0.0", options.port),
                on: threads)
            return
        }

        let authority:any ServerAuthority = try options.authority.load(
            certificates: options.certificates)

        let mongodb:Mongo.DriverBootstrap = MongoDB / [options.mongo] /?
        {
            $0.executors = .shared(threads)
            $0.appname = "Unidoc Server"
        }

        defer
        {
            try? threads.syncShutdownGracefully()
        }

        try await mongodb.withSessionPool
        {
            let delegate:Self = .init(
                database: try await .setup("unidoc", in: $0),
                mongodb: $0,
                reload: options.reload)

            try await withThrowingTaskGroup(of: Void.self)
            {
                (tasks:inout ThrowingTaskGroup<Void, any Error>) in

                tasks.addTask
                {
                    try await delegate.serve(from: ("0.0.0.0", options.port),
                        as: authority,
                        on: threads)
                }
                tasks.addTask
                {
                    try await delegate.respond(on: threads)
                }

                for try await _:Void in tasks
                {
                    tasks.cancelAll()
                }
            }
        }
    }
}
