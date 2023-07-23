import HTTPServer
import MongoDB
import NIOCore
import NIOPosix
import NIOHTTP1
import UnidocDatabase

final
actor Delegate
{
    private nonisolated
    let requests:(in:AsyncStream<AnyRequest>.Continuation, out:AsyncStream<AnyRequest>)

    private nonisolated
    let database:Database
    private nonisolated
    let mongodb:Mongo.SessionPool

    private nonisolated
    let cache:Cache<Get.Asset>

    private
    init(reloading mode:CacheReloading, database:Database, mongodb:Mongo.SessionPool)
    {
        var continuation:AsyncStream<AnyRequest>.Continuation? = nil
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
        for await request:AnyRequest in self.requests.out
        {
            try Task.checkCancellation()

            let response:ServerResponse?
            do
            {
                switch request
                {
                case .get(let request):
                    switch request.branch
                    {
                    case .admin(let admin):
                        response = try await admin.load(pool: self.mongodb)

                    case .asset(let asset):
                        response = try await asset.load(from: self.cache)

                    case .db(let db):
                        response = try await db.load(from: self.database, pool: self.mongodb)
                    }

                case .post(let request):
                    response = try await request.respond(
                        using: self.database,
                        in: self.mongodb)
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
    func serve(get request:GetRequest)
    {
        switch self.requests.in.yield(.get(request))
        {
        case .enqueued: return
        case _:         fatalError("unimplemented")
        }
    }
    nonisolated
    func serve(post request:PostRequest)
    {
        switch self.requests.in.yield(.post(request))
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
