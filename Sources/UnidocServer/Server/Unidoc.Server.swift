import Atomics
import GitHubAPI
import HTTP
import HTTPServer
import ISO
import MD5
import MongoDB
import NIOPosix
import NIOSSL
import PieCharts
import Symbols
import UnidocRender
import UnixTime

extension Unidoc
{
    public final
    class Server:Sendable
    {
        let clientIdentity:NIOSSLContext

        let coordinators:[Symbol.Triple: BuildCoordinator]
        let plugins:[String: PluginHandle]

        @usableFromInline
        let options:ServerOptions

        public
        let db:Database

        private
        let metricQueue:AsyncStream<MetricPaint>.Continuation,
            metrics:AsyncStream<MetricPaint>

        private
        let updateQueue:AsyncStream<Update>.Continuation,
            updates:AsyncStream<Update>

        let policy:(any HTTP.ServerPolicy)?
        @usableFromInline
        let logger:any ServerLogger

        public
        init(clientIdentity:NIOSSLContext,
            coordinators:[BuildCoordinator],
            plugins:[any Plugin],
            options:ServerOptions,
            logger:any ServerLogger,
            db:Database)
        {
            var policy:(any HTTP.ServerPolicy)? = nil

            for case let plugin as any HTTP.ServerPolicy in plugins
            {
                policy = plugin
                break
            }

            self.clientIdentity = clientIdentity
            self.coordinators = coordinators.reduce(into: [:])
            {
                $0[$1.id] = $1
            }
            self.plugins = plugins.reduce(into: [:])
            {
                $0[type(of: $1).id] = .init(plugin: $1)
            }
            self.options = options
            self.policy = policy
            self.logger = logger
            self.db = db

            (self.metrics, self.metricQueue) = AsyncStream<MetricPaint>.makeStream(
                bufferingPolicy: .bufferingOldest(32))
            (self.updates, self.updateQueue) = AsyncStream<Update>.makeStream(
                bufferingPolicy: .bufferingOldest(16))
        }
    }
}
extension Unidoc.Server
{
    @inlinable public
    var github:(any GitHub.Integration)? { self.options.github }

    @inlinable public
    var bucket:Unidoc.Buckets { self.options.bucket }


    func format() -> Unidoc.RenderFormat
    {
        self.format(username: nil, locale: nil, time: .now())
    }

    private
    func format(for request:Unidoc.ServerRequest) -> Unidoc.RenderFormat
    {
        let username:String?

        if  case .web(let session?, _) = request.authorization
        {
            username = session.symbol
        }
        else
        {
            username = nil
        }

        return self.format(username: username,
            locale: request.client?.locale,
            time: request.accepted)
    }

    private
    func format(username:String?,
        locale:ISO.Locale?,
        time:UnixAttosecond) -> Unidoc.RenderFormat
    {
        .init(
            access: self.db.settings.access,
            assets: self.options.assetCache == nil ? .cloudfront : .local,
            origin: self.options.origin,
            preview: self.options.preview,
            username: username,
            locale: locale ?? .init(language: .en),
            theme: nil,
            time: time)
    }
}
extension Unidoc.Server
{
    //  TODO: this really should be manually-triggered and should not run every time.
    func _setup() async throws
    {
        let db:Unidoc.DB = try await self.db.session()

        do
        {
            try await db.setup()
        }
        catch let error
        {
            print(error)
            print("""
                warning: some indexes are no longer valid, \
                the database '\(db.id)' likely needs to be rebuilt
                """)
        }

        //  Create the machine users, if they doesn’t exist. Don’t store the cookie, since we
        //  want to be able to change it without restarting the server.
        for number:Int in 0 ..< self.options.builders
        {
            let id:UInt32 = .init(number)
            let _:Unidoc.UserSecrets = try await db.users.update(user: .init(machine: id))
        }
    }

    func update() async throws
    {
        for await update:Update in self.updates
        {
            try Task.checkCancellation()

            let promise:Promise = update.promise
            let payload:[UInt8] = update.payload

            await update.operation.serve(request: promise, with: payload, from: self)
        }
    }

    func run<Plugin>(plugin:Plugin, while active:ManagedAtomic<Bool>) async throws
        where Plugin:Unidoc.Plugin
    {
        while true
        {
            //  If we caught an error, it was probably because mongod is restarting.
            //  We should wait a little while for it to come back online.
            async
            let cooldown:Void = Task.sleep(for: Plugin.cooldown)

            epoch:
            do
            {
                guard active.load(ordering: .relaxed)
                else
                {
                    break epoch
                }

                let started:ContinuousClock.Instant = .now
                let context:Unidoc.PluginContext = .init(
                    logger: self.logger,
                    plugin: Plugin.id,
                    client: self.clientIdentity,
                    db: try await self.db.session())

                guard
                let period:Duration = try await plugin.run(in: context)
                else
                {
                    break epoch
                }

                try await Task.sleep(until: started + period)
            }
            catch let error
            {
                self.logger.log(
                    as: .plugin(Plugin.id),
                    at: .now(), //  This could be a while since `started` was set.
                    reflecting: error)
            }

            try await cooldown
        }
    }
}
extension Unidoc.Server
{
    func paint(with paint:Unidoc.MetricPaint)
    {
        self.metricQueue.yield(paint)
    }

    func paint() async throws
    {
        for await paint:Unidoc.MetricPaint in self.metrics
        {
            try Task.checkCancellation()
            /// It could be a potentially long time between events, so we acquire a fresh
            /// session each time.
            do
            {
                let db:Unidoc.DB = try await self.db.session()
                try await db.searchbotGrid.count(vertex: paint.vertex,
                    in: paint.volume,
                    as: paint.searchbot,
                    at: paint.time)
            }
            catch let error
            {
                self.logger.log(error: error)
            }
        }
    }
}

extension Unidoc.Server
{
    public
    func log(event:HTTP.ServerEvent, ip origin:HTTP.ServerRequest.Origin?)
    {
        let error:any Error
        let level:Unidoc.ServerLog.Level
        let layer:String

        switch event
        {
        case .application(let underlying):
            error = underlying
            level = .error
            layer = "Application"

        case .http1(let underlying):
            error = underlying
            level = .debug
            layer = "HTTP/1"

        case .http2(let underlying):
            error = underlying
            level = .debug
            layer = "HTTP/2"

        case .tcp(let underlying):
            error = underlying
            level = .debug
            layer = "TCP"
        }

        self.logger.log(as: .global(level), at: .now())
        {
            $0[.dl]
            {
                $0[.dt] = "Error type"
                $0[.dd] = "\(String.init(reflecting: Swift.type(of: error))) (\(layer))"

                $0[.dt] = "Origin"
                $0[.dd] = origin?.ip.description ?? "unknown"
            }

            $0[.pre] = String.init(reflecting: error)
        }
    }
}
extension Unidoc.Server
{
    private
    func clearance(by authorization:Unidoc.Authorization) async throws -> HTTP.ServerResponse?
    {
        guard case .enforced = self.options.access
        else
        {
            return nil
        }

        let user:Unidoc.UserSession

        switch authorization
        {
        case .invalid(let error):   return .unauthorized("\(error)\n")
        case .web(nil, _):          return .unauthorized("Unauthorized\n")
        case .web(let session?, _): user = .web(session)
        case .api(let session):     user = .api(session)
        }

        let db:Unidoc.DB = try await self.db.session()

        guard
        let rights:Unidoc.UserRights = try await db.users.validate(user: user)
        else
        {
            return .notFound("No such user\n")
        }

        switch rights.level
        {
        case .administratrix:   return nil
        case .machine:          return nil
        case .human:            return .forbidden("")
        case .guest:            return .unauthorized("")
        }
    }
}

extension Unidoc.Server
{
    public
    func reject(request:HTTP.ServerRequest) async throws -> HTTP.ServerResponse?
    {
        try await self.clearance(by: request.headers.authorization)
    }

    public
    func delete(request:Unidoc.ServerRequest) async throws -> HTTP.ServerResponse
    {
        return .resource("Method not allowed\n", status: 405)
    }

    public
    func get(request:Unidoc.ServerRequest) async throws -> HTTP.ServerResponse
    {
        var router:Unidoc.Router = .init(routing: request)

        guard
        let route:Unidoc.AnyOperation = router.get()
        else
        {
            return .resource("Malformed request\n", status: 400)
        }

        return try await self.response(running: route, for: request)
    }

    public
    func post(request:Unidoc.ServerRequest, body:[UInt8]) async throws -> HTTP.ServerResponse
    {
        var router:Unidoc.Router = .init(routing: request)

        guard
        let operation:Unidoc.AnyOperation = router.post(body: body)
        else
        {
            return .resource("Malformed request\n", status: 400)
        }

        return try await self.response(running: operation, for: request)
    }

    public
    func put(request:HTTP.ServerRequest, body:[UInt8]) async -> HTTP.ServerResponse
    {
        guard
        let request:Unidoc.StreamedRequest = .init(from: request)
        else
        {
            return .resource("Malformed request\n", status: 400)
        }

        return await self.submit(update: request.endpoint, with: body)
    }

    private
    func response(running operation:Unidoc.AnyOperation,
        for request:Unidoc.ServerRequest) async throws -> HTTP.ServerResponse
    {
        switch operation
        {
        case .unordered(let operation):
            return try await self.respond(to: request, running: operation)

        case .update(let procedural):
            if  let failure:HTTP.ServerResponse = try await self.clearance(
                    by: request.authorization)
            {
                return failure
            }

            return await self.submit(update: procedural)

        case .sync(let response):
            self.logger.log(.init(duration: .zero,
                response: response,
                request: request))

            return response

        case .syncHTML(let renderable):
            let response:HTTP.ServerResponse = renderable.response(
                format: self.format(for: request))

            self.logger.log(.init(duration: .zero,
                response: response,
                request: request))

            return response

        case .syncLoad(let request):
            //  In production mode, static assets are served by Cloudfront.
            return try await self.options.assetCache?.serve(request) ?? .forbidden("")
        }
    }
}
extension Unidoc.Server
{
    private
    func submit(update operation:any Unidoc.ProceduralOperation,
        with body:[UInt8] = []) async -> HTTP.ServerResponse
    {
        await withCheckedContinuation
        {
            guard case .enqueued = self.updateQueue.yield(.init(operation: operation,
                payload: body,
                promise: .init($0)))
            else
            {
                $0.resume(returning: .resource("", status: 503))
                return
            }
        }
    }

    /// As this function participates in cooperative cancellation, it can throw, and the only
    /// error it can throw is a ``CancellationError``.
    private
    func respond(to request:Unidoc.ServerRequest,
        running operation:any Unidoc.InteractiveOperation) async throws -> HTTP.ServerResponse
    {
        try Task.checkCancellation()

        let initiated:ContinuousClock.Instant = .now
        let response:HTTP.ServerResponse
        let format:Unidoc.RenderFormat = self.format(for: request)

        run: do
        {
            let context:Unidoc.ServerResponseContext = .init(request: request,
                format: format,
                server: self)

            if  case "true"? = request.parameter("_explain"),
                case let operation as any Unidoc.ExplainableOperation = operation
            {
                let db:Unidoc.DB = try await self.db.session()
                response = try await operation.explain(with: db)
                break run
            }

            switch try await operation.load(with: context)
            {
            case .resource(var resource, status: let status)?:
                //  It would only make sense to compute an etag if the content is at least twice
                //  as large as the hash itself. Moreover, some queries are able to cache
                //  responses at the database level, so this avoids having to parse the `etag`
                //  header field twice.
                if  let content:HTTP.Resource.Content = resource.content,
                    content.body.size >= 32,
                    status == 200 || status == 300
                {
                    let hash:MD5 = resource.hash ?? content.hash()
                    resource.hash = hash
                    if  case hash? = request.headers.etag
                    {
                        resource.content = nil
                    }
                }

                response = .resource(resource, status: status)

            case let unoptimized?:
                response = unoptimized

            case nil:
                response = .notFound("not found\n")
            }
        }
        catch let error as CancellationError
        {
            throw error
        }
        catch let error
        {
            self.logger.log(as: .global(.error), at: format.time)
            {
                $0[.dl]
                {
                    $0[.dt] = "Error type"
                    $0[.dd] = String.init(reflecting: Swift.type(of: error))

                    $0[.dt] = "Request origin"
                    $0[.dd] = "\(request.origin.ip)"

                    $0[.dt] = "Request"
                    $0[.dd] = "\(request.uri)"
                }

                $0[.pre] = String.init(reflecting: error)
            }

            let errorPage:Unidoc.ServerErrorPage = .init(error: error)
            let html:HTTP.Resource = errorPage.resource(format: format)

            /// This will still look the same to humans, but it will not appear as if
            /// the server is down to Googlebot.
            return self.options.preview ? .error(html) : .unauthorized(html)
        }

        switch operation
        {
        //  Don’t log traffic from the builders.
        case is Unidoc.BuilderLabelOperation:   return response
        case is Unidoc.BuilderPollOperation:    return response
        //  Don’t log these operations, as doing so would make it impossible for admins to
        //  avoid leaving trails.
        case is Unidoc.LoadDashboardOperation:  return response
        case is Unidoc.LoginOperation:          return response
        case is Unidoc.AuthOperation:           return response
        default:                                break
        }

        self.logger.log(.init(duration: .now - initiated,
            response: response,
            request: request))

        return response
    }
}
