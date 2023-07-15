import HTML
import HTTPServer
import MongoDB
import Multiparts
import NIOCore
import NIOPosix
import NIOHTTP1
import SymbolGraphs
import UnidocDatabase
import URI

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
            do
            {
                let resource:ServerResource
                switch request
                {
                case .get(let request):
                    resource = try await self.respond(to: request)

                case .post(let request):
                    resource = try await self.respond(to: request)
                }
                request.promise.succeed(resource)
            }
            catch let error
            {
                request.promise.fail(error)
            }
        }
    }

    private nonisolated
    func respond(to request:GetRequest) async throws -> ServerResource
    {
        let path:[String] = request.uri.path.normalized()
        switch path
        {
        case ["admin"]:
            let page:Site.AdminPage = .init(configuration: try await self.mongodb.run(
                command: Mongo.ReplicaSetGetConfiguration.init(),
                against: .admin))

            let html:HTML = .document { $0[.html] { $0[.lang] = "en" } = page }

            return .init(location: "\(request.uri)",
                response: .content(.init(.binary(html.utf8),
                    type: .text(.html, charset: .utf8))),
                results: .one(canonical: "/admin"))

        case ["admin", "drop-database"]:
            let page:Site.AdminPage.DropDatabase = .init()
            let html:HTML = .document { $0[.html] { $0[.lang] = "en" } = page }

            return .init(location: "\(request.uri)",
                response: .content(.init(.binary(html.utf8),
                    type: .text(.html, charset: .utf8))),
                results: .one(canonical: "/admin/drop-database"))

        case _:
            break
        }

        switch (path.first, path.count)
        {
        case ("docs"?, 2...):
            guard   let query:DeepQuery = .init(path[1], path[2...]),
                    let page:Site.Docs.DeepPage = .init(try await self.database.execute(
                        query: query,
                        with: try await .init(from: self.mongodb)))
            else
            {
                fallthrough
            }

            let html:HTML = .document { $0[.html] { $0[.lang] = "en" } = page }
            let location:String = "\(page.location)"

            return .init(location: location,
                response: .content(.init(.binary(html.utf8),
                    type: .text(.html, charset: .utf8))),
                results: .one(canonical: location))

        case (_, _):
            return .init(location: "\(request.uri)",
                response: .content(.init(.text("not found"),
                    type: .text(.plain, charset: .utf8))),
                results: .none)
        }
    }

    private nonisolated
    func respond(to request:PostRequest) async throws -> ServerResource
    {
        let display:String?
        switch request.uri.path.normalized() as [String]
        {
        case ["admin", "action", "rebuild"]:
            let session:Mongo.Session = try await .init(from: self.mongodb)
            let rebuilt:Int = try await self.database.rebuild(with: session)
            display = "(rebuilt \(rebuilt) snapshots)"

        case ["admin", "action", "upload"]:
            var receipts:[SnapshotReceipt] = []
            for item:MultipartForm.Item in request.form
                where item.header.name == "documentation-binary"
            {
                receipts.append(try await self.ingest(uploaded: try .init(buffer: item.value)))
            }
            display = "\(receipts)"

        case ["admin", "action", "drop-database"]:
            let session:Mongo.Session = try await .init(from: self.mongodb)
            try await self.database.nuke(with: session)
            display = "(reinitialized database)"

        case _:
            display = nil
        }

        if  let display:String
        {
            let _location:String = "\(request.uri)"
            return .init(location: _location,
                    response: .content(.init(.text("success! \(display)"),
                        type: .text(.plain, charset: .utf8))),
                    results: .one(canonical: _location))
        }
        else
        {
            return .init(location: "\(request.uri)",
                response: .content(.init(.text("not found"),
                    type: .text(.plain, charset: .utf8))),
                results: .none)
        }
    }
}

extension Delegate
{
    private nonisolated
    func ingest(uploaded docs:Documentation) async throws -> SnapshotReceipt
    {
        if  let _:String = docs.metadata.id
        {
            let session:Mongo.Session = try await .init(from: self.mongodb)
            return try await self.database.publish(docs: docs, with: session)
        }
        else
        {
            throw DocumentationIdentificationError.init()
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
            let delegate:Self = .init(database: try await .setup("unidoc", in: $0),
                mongodb: $0)

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
