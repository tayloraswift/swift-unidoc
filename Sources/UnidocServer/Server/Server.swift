import Backtrace
import GitHubClient
import GitHubIntegration
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

final
actor Server
{
    private nonisolated
    let requests:(in:AsyncStream<Request>.Continuation, out:AsyncStream<Request>)

    private nonisolated
    let database:Services.Database

    private nonisolated
    let cache:Cache<Site.Asset.Get>

    private nonisolated
    let mode:ServerMode

    private
    init(database:Services.Database, mode:ServerMode)
    {
        var continuation:AsyncStream<Request>.Continuation? = nil
        self.requests.out = .init
        {
            continuation = $0
        }
        self.requests.in = continuation!

        self.database = database
        self.cache = .init(source: "Assets", reload: mode == .unsecured)
        self.mode = mode
    }
}
extension Server
{
    func respond(on threads:MultiThreadedEventLoopGroup) async throws
    {
        //  This is a client context, which is different from the server context.
        let niossl:NIOSSLContext = try .init(configuration: .makeClientConfiguration())
        var services:Services

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

            let auth:HTTP2Client = .init(threads: threads,
                niossl: niossl,
                remote: "github.com")
            let api:HTTP2Client = .init(threads: threads,
                niossl: niossl,
                remote: "api.github.com")

            services = .init(
                database: self.database,
                github:
                (
                    oauth: .init(http2: auth, app: .init(
                        client: "2378cacaed3ace362867",
                        secret: trim(secret.oauth))),

                    app: .init(http2: auth, app: .init(383005,
                        client: "Iv1.dba609d35c70bf57",
                        secret: trim(secret.app))),
                    api: .init(http2: api, app: .init(
                        agent: "Swiftinit (by tayloraswift)"))
                ),
                mode: self.mode)
        }
        else
        {
            print("Note: App secret unavailable, GitHub integration has been disabled!")
            services = .init(database: self.database, github: nil)
        }

        for await request:Request in self.requests.out
        {
            try Task.checkCancellation()

            do
            {
                let type:WritableKeyPath<ServerTour.Stats.ByType, Int> =
                    request.operation.statisticalType

                let response:ServerResponse = try await request.operation.load(
                    from: services,
                    with: request.cookies)
                    ?? .resource(.init(.none,
                        content: .string("not found"),
                        type: .text(.plain, charset: .utf8)))

                services.tour.stats.requests[keyPath: type] += 1

                let status:WritableKeyPath<ServerTour.Stats.ByStatus, Int>
                switch response
                {
                case .resource(let resource):
                    services.tour.stats.bytes[keyPath: type] += resource.content.size
                    status = resource.statisticalStatus

                case .redirect(.temporary, _):
                    status = \.redirectedTemporarily

                case .redirect(.permanent, _):
                    status = \.redirectedPermanently
                }

                //  Don’t count visits to the admin dashboard.
                if  type != \.restricted
                {
                    services.tour.stats.responses[keyPath: status] += 1
                }

                request.promise.succeed(response)
            }
            catch let error
            {
                request.promise.fail(error)
            }
        }
    }
}
extension Server:HTTPServerDelegate
{
    nonisolated
    func submit(_ operation:Operation, promise:EventLoopPromise<ServerResponse>)
    {
        switch operation.endpoint
        {
        case .stateless(let stateless):
            promise.succeed(stateless)

        case .static(let asset):
            promise.completeWithTask
            {
                try await asset.load(from: self.cache)
            }

        case .stateful(let stateful):
            let request:Request = .init(operation: stateful,
                cookies: operation.cookies,
                promise: promise)

            guard case .enqueued = self.requests.in.yield(request)
            else
            {
                fatalError("unimplemented")
            }
        }
    }
}

@main
extension Server
{
    public static
    func main() async throws
    {
        Backtrace.install()

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
            let mode:ServerMode

            switch type(of: authority).scheme
            {
            case .https:    mode = .secured
            case .http:     mode = .unsecured
            }

            let delegate:Self = .init(database: .init(
                    sessions: $0,
                    account: await .setup(as: "accounts", in: $0),
                    package: await .setup(as: "packages", in: $0),
                    unidoc: await .setup(as: "unidoc", in: $0)),
                mode: mode)

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
