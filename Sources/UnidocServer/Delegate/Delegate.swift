import HTTPServer
import MongoDB
import NIOCore
import NIOPosix
import NIOHTTP1
import UnidocDatabase
import UnidocPages

final
actor Delegate
{
    private nonisolated
    let requests:(in:AsyncStream<Request>.Continuation, out:AsyncStream<Request>)

    private nonisolated
    let database:Database
    private nonisolated
    let mongodb:Mongo.SessionPool

    private nonisolated
    let cache:Cache<Site.Asset>

    private
    init(reloading mode:CacheReloading, database:Database, mongodb:Mongo.SessionPool)
    {
        var continuation:AsyncStream<Request>.Continuation? = nil
        self.requests.out = .init
        {
            continuation = $0
        }
        self.requests.in = continuation!

        self.database = database
        self.mongodb = mongodb

        self.cache = .init(reloading: mode, from: "Assets")
    }
}
extension Delegate
{
    func respond() async throws
    {
        for await request:Request in self.requests.out
        {
            try Task.checkCancellation()

            let response:ServerResponse?
            do
            {
                switch request.operation
                {
                case .database(let operation):
                    response = try await operation.load(from: self.database,
                        pool: self.mongodb)

                case .datafile(let asset):
                    response = try await asset.load(from: self.cache)

                case .dataless(let operation):
                    response = try operation.load()
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
                    content: .text("not found"),
                    type: .text(.plain, charset: .utf8))))
            }
        }
    }
}
extension Delegate:ServerDelegate
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
extension Delegate
{
    public static
    func main() async throws
    {
        let executors:MultiThreadedEventLoopGroup = .init(numberOfThreads: 2)
        let options:Options = try .parse()
        if  options.redirect
        {
            try await options.authority.type.redirect(from: ("0.0.0.0", options.port),
                on: executors)
            return
        }

        let authority:any ServerAuthority = try options.authority.load(
            certificates: options.certificates)

        let mongodb:Mongo.DriverBootstrap = MongoDB / [options.mongo] /?
        {
            $0.executors = .shared(executors)
            $0.appname = "Unidoc Server"
        }

        defer
        {
            try? executors.syncShutdownGracefully()
        }

        try await mongodb.withSessionPool
        {
            let delegate:Self = .init(reloading: options.reloading,
                database: try await .setup("unidoc", in: $0),
                mongodb: $0)

            try await withThrowingTaskGroup(of: Void.self)
            {
                (tasks:inout ThrowingTaskGroup<Void, any Error>) in

                tasks.addTask
                {
                    try await delegate.serve(from: ("0.0.0.0", options.port),
                        as: authority,
                        on: executors)
                }
                tasks.addTask
                {
                    try await delegate.respond()
                }

                for try await _:Void in tasks
                {
                    tasks.cancelAll()
                }
            }
        }
    }
}
