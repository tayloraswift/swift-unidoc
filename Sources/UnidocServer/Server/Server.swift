import HTTP
import HTTPClient
import HTTPServer
import MongoDB
import NIOCore
import NIOPosix
import NIOHTTP1
import NIOSSL
import System
import UnidocDB
import UnidocPages
import UnidocQueries
import UnidocRecords

struct Server:Sendable
{
    private
    let authority:any ServerAuthority
    private
    let port:Int

    private
    let requests:(in:AsyncStream<Request>.Continuation, out:AsyncStream<Request>)

    private
    let github:GitHubPlugin?
    private
    let cache:Cache<Site.Asset.Get>


    let mode:ServerMode
    let db:DB

    private
    init(authority:any ServerAuthority,
        port:Int,
        github:GitHubPlugin?,
        cache:Cache<Site.Asset.Get>,
        mode:ServerMode,
        db:DB)
    {
        self.authority = authority
        self.port = port

        var continuation:AsyncStream<Request>.Continuation? = nil
        self.requests.out = .init
        {
            continuation = $0
        }
        self.requests.in = continuation!

        self.github = github
        self.cache = cache


        self.mode = mode
        self.db = db
    }
}
extension Server
{
    init(options:__shared Options, mongodb:__owned Mongo.SessionPool) async throws
    {
        let authority:any ServerAuthority = try options.authority.load(
            certificates: options.certificates)

        let cache:Cache<Site.Asset.Get>
        let mode:ServerMode

        switch type(of: authority).scheme
        {
        case .https:
            cache = .init(reload: false)
            mode = .secured

        case .http:
            cache = .init(reload: true)
            mode = .unsecured
        }

        let github:GitHubPlugin?
        if  let secret:(oauth:String, app:String) = try?
            (
                (cache.assets / "secrets" / "github-oauth-secret").read(),
                (cache.assets / "secrets" / "github-app-secret").read()
            )
        {
            //  This is a client context, which is different from the server context.
            let niossl:NIOSSLContext = try .init(configuration: .makeClientConfiguration())

            func trim(_ string:String) -> String
            {
                .init(string.prefix(while: \.isHexDigit))
            }

            github = .init(niossl: niossl,
                oauth: .init(
                    client: "2378cacaed3ace362867",
                    secret: trim(secret.oauth)),
                app: .init(383005,
                    client: "Iv1.dba609d35c70bf57",
                    secret: trim(secret.app)))
        }
        else
        {
            print("Note: App secret unavailable, GitHub integration has been disabled!")
            github = nil
        }

        self.init(
            authority: authority,
            port: options.port,
            github: github,
            cache: cache,
            mode: mode,
            db: .init(sessions: mongodb,
                account: await .setup(as: "accounts", in: mongodb),
                package: await .setup(as: "packages", in: mongodb),
                unidoc: await .setup(as: "unidoc", in: mongodb)))
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
            let server:Self = try await .init(options: options, mongodb: $0)
            try await server.main(on: threads)
        }
    }

    private
    func main(on threads:MultiThreadedEventLoopGroup) async throws
    {
        try await withThrowingTaskGroup(of: Void.self)
        {
            (tasks:inout ThrowingTaskGroup<Void, any Error>) in

            tasks.addTask
            {
                try await self.serve(from: ("0.0.0.0", self.port),
                    as: self.authority,
                    on: threads)
            }
            tasks.addTask
            {
                var state:State = .init(server: self,
                    github: try self.github?.partner(on: threads))

                try await state.respond(to: self.requests.out)
            }

            if  let github:GitHubPlugin = self.github
            {
                tasks.addTask
                {
                    try await github.crawl(on: threads, db: self.db)
                }
            }

            for try await _:Void in tasks
            {
                tasks.cancelAll()
            }
        }
    }
}
extension Server:HTTPServerDelegate
{
    func submit(_ operation:Operation, promise:EventLoopPromise<ServerResponse>)
    {
        switch operation.endpoint
        {
        case .interactive(let interactive):
            let request:Request = .init(operation: interactive,
                cookies: operation.cookies,
                promise: promise)

            guard case .enqueued = self.requests.in.yield(request)
            else
            {
                fatalError("unimplemented")
            }

        case .stateless(let stateless):
            promise.succeed(stateless)

        case .static(let asset):
            promise.completeWithTask
            {
                try await asset.load(from: self.cache)
            }
        }
    }
}
