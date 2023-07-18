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

    private
    init(database:Database, mongodb:Mongo.SessionPool)
    {
        var continuation:AsyncStream<AnyRequest>.Continuation? = nil
        self.requests.out = .init
        {
            continuation = $0
        }
        self.requests.in = continuation!

        self.database = database
        self.mongodb = mongodb
    }
}
extension Delegate
{
    func respond() async throws
    {
        for await request:AnyRequest in self.requests.out
        {
            try Task.checkCancellation()

            let resource:ServerResource?
            do
            {
                switch request
                {
                case .get(let request):
                    resource = try await request.respond(
                        using: self.database,
                        in: self.mongodb)

                case .post(let request):
                    resource = try await request.respond(
                        using: self.database,
                        in: self.mongodb)
                }
            }
            catch let error
            {
                request.promise.fail(error)
                continue
            }

            if  let resource:ServerResource
            {
                request.promise.succeed(resource)
            }
            else
            {
                request.promise.succeed(.init(location: "\(request.uri)",
                    response: .content(.init(.text("not found"),
                        type: .text(.plain, charset: .utf8))),
                    results: .none))
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
        let options:Options = try .parse()

        let authority:any ServerAuthority = try options.authority.load(
            certificates: options.certificates)

        let executors:MultiThreadedEventLoopGroup = .init(numberOfThreads: 2)
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
            let delegate:Self = .init(database: try await .setup("unidoc", in: $0),
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
