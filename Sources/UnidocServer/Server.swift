import Atomics
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
    let interactive:
    (
        consumer:AsyncStream<Request<any InteractiveEndpoint>>.Continuation,
        requests:AsyncStream<Request<any InteractiveEndpoint>>
    )
    private
    let procedural:
    (
        consumer:AsyncStream<Request<any ProceduralEndpoint>>.Continuation,
        requests:AsyncStream<Request<any ProceduralEndpoint>>
    )

    private
    let github:GitHubPlugin?
    let mode:Mode

    let meter:HTTP.ServerMeter
    let count:Counters
    let db:DB

    private
    init(authority:any ServerAuthority,
        port:Int,
        mode:Mode,
        github:GitHubPlugin?,
        db:DB)
    {
        self.authority = authority
        self.port = port

        do
        {
            var continuation:AsyncStream<Request<any InteractiveEndpoint>>.Continuation? = nil
            self.interactive.requests = .init(bufferingPolicy: .bufferingOldest(128))
            {
                continuation = $0
            }
            self.interactive.consumer = continuation!
        }
        do
        {
            var continuation:AsyncStream<Request<any ProceduralEndpoint>>.Continuation? = nil
            self.procedural.requests = .init(bufferingPolicy: .bufferingOldest(16))
            {
                continuation = $0
            }
            self.procedural.consumer = continuation!
        }

        self.github = github
        self.meter = .init()
        self.count = .init()

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

        let assets:FilePath = "Assets"
        let mode:Mode

        if  authority is Localhost
        {
            mode = .development(.init(source: assets))
        }
        else
        {
            mode = .production
        }

        let github:GitHubPlugin?
        gi:
        do
        {
            guard options.github
            else
            {
                github = nil
                break gi
            }

            //  This is a client context, which is different from the server context.
            let niossl:NIOSSLContext = try .init(configuration: .makeClientConfiguration())

            github = .init(niossl: niossl,
                oauth: .init(
                    client: "2378cacaed3ace362867",
                    secret: try (assets / "secrets" / "github-oauth-secret").readLine()),
                app: .init(383005,
                    client: "Iv1.dba609d35c70bf57",
                    secret: try (assets / "secrets" / "github-app-secret").readLine()),
                pat: try (assets / "secrets" / "github-pat").readLine())
        }
        catch
        {
            Log[.debug] = "App secret unavailable, GitHub integration has been disabled!"
            github = nil
        }

        self.init(
            authority: authority,
            port: options.port,
            mode: mode,
            github: github,
            db: .init(sessions: mongodb,
                account: await .setup(as: "accounts", in: mongodb),
                unidoc: await .setup(as: "unidoc", in: mongodb)))
    }
}
extension Server
{
    var assets:StaticAssets
    {
        guard self.mode.secured
        else
        {
            return .init(version: nil)
        }

        //  Eventually, this should be dynamically configurable. But for now, we just
        //  hard-code the version number.
        return .init(version: .v(1, 1))
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
        let session:Mongo.Session = try await .init(from: self.db.sessions)

        //  Create the machine user, if it doesn’t exist. Don’t store the cookie, since we
        //  want to be able to change it without restarting the server.
        let _:Account.Cookie = try await self.db.account.users.update(
            account: .machine(0),
            with: session)

        _ = consume session

        try await withThrowingTaskGroup(of: Void.self)
        {
            (tasks:inout ThrowingTaskGroup<Void, any Error>) in

            // tasks.addTask
            // {
            //     try await self.serve(from: ("0.0.0.0", self.port),
            //         as: self.authority,
            //         on: threads)
            // }
            tasks.addTask
            {
                try await self.serve(from: ("::", self.port),
                    as: self.authority,
                    on: threads)
            }
            tasks.addTask
            {
                var state:InteractiveState = .init(server: self,
                    github: try self.github?.partner(on: threads))

                try await state.respond(to: self.interactive.requests)
            }
            tasks.addTask
            {
                var state:ProceduralState = .init(server: self)

                try await state.respond(to: self.procedural.requests)
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
            let request:Request<any InteractiveEndpoint> = .init(endpoint: interactive,
                cookies: operation.cookies,
                profile: operation.profile,
                promise: promise)

            switch self.interactive.consumer.yield(request)
            {
            case .enqueued:
                return

            case .dropped:
                self.count.requestsDropped.wrappingIncrement(ordering: .relaxed)

                promise.succeed(.unavailable("""
                    The site is currently experiencing exceptionally high traffic. \
                    Please try again later.
                    """))

            case .terminated:
                fatalError("stream terminated")

            @unknown case _:
                fatalError("unimplemented")
            }

        case .procedural(let procedural):
            let request:Request<any ProceduralEndpoint> = .init(endpoint: procedural,
                cookies: operation.cookies,
                profile: operation.profile,
                promise: promise)

            guard case .enqueued = self.procedural.consumer.yield(request)
            else
            {
                fatalError("unimplemented")
            }

        case .stateless(let stateless):
            promise.succeed(.ok(stateless.resource(assets: self.assets)))

        case .static(let request):
            if  case .development(let cache) = self.mode
            {
                promise.completeWithTask
                {
                    try await cache.serve(request)
                }
            }
            else
            {
                //  In production mode, static assets are served by Cloudfront.
                promise.succeed(.forbidden(""))
            }
        }
    }
}
