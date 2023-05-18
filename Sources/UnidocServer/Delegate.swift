import MongoDB
import NIOCore
import NIOPosix
import NIOHTTP1
import HTTPServer

final
actor Delegate
{
    private nonisolated
    let requests:(in:AsyncStream<GetRequest>.Continuation, out:AsyncStream<GetRequest>)

    private
    var mongodb:Mongo.SessionPool

    init(mongodb:Mongo.SessionPool)
    {
        var continuation:AsyncStream<GetRequest>.Continuation? = nil
        self.requests.out = .init
        {
            continuation = $0
        }
        self.requests.in = continuation!

        self.mongodb = mongodb
    }
}
extension Delegate
{
    func serve() async throws
    {
        for await request:GetRequest in self.requests.out
        {
            try Task.checkCancellation()

            do
            {

                let configuration:Mongo.ReplicaSetConfiguration = try await self.mongodb.run(
                    command: Mongo.ReplicaSetGetConfiguration.init(),
                    against: .admin)

                request.promise.succeed(.init(location: request.uri,
                    response: .media(.init(.text("\(configuration)"),
                        type: .text(.plain, charset: .utf8))),
                    results: .one(canonical: request.uri)))
            }
            catch let error
            {
                request.promise.fail(error)
            }
        }
    }
}
extension Delegate
{
    struct GetRequest:Sendable
    {
        let uri:String
        let promise:EventLoopPromise<ServerResource>

        init(uri:String, promise:EventLoopPromise<ServerResource>)
        {
            self.uri = uri
            self.promise = promise
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
        self.init(uri: uri, promise: promise())
    }
}
extension Delegate:ServerDelegate
{
    nonisolated
    func serve(get request:GetRequest)
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
        let mongodb:Mongo.DriverBootstrap = MongoDB / ["unidoc-mongod"] /?
        {
            $0.executors = .shared(executors)
            $0.appname = "example app"
        }

        defer
        {
            try? executors.syncShutdownGracefully()
        }

        try await mongodb.withSessionPool
        {
            let delegate:Self = .init(mongodb: $0)

            try await withThrowingTaskGroup(of: Void.self)
            {
                (tasks:inout ThrowingTaskGroup<Void, any Error>) in

                tasks.addTask
                {
                    try await delegate.serve(from: ("0.0.0.0", 8080),
                        as: .localhost,
                        on: executors)
                }
                tasks.addTask
                {
                    try await delegate.serve()
                }

                for try await _:Void in tasks
                {
                    tasks.cancelAll()
                }
            }
        }
    }
}
