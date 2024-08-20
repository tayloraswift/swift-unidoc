import GitHubAPI
import HTTP
import HTTPServer
import ISO
import MongoDB
import PieCharts
import UnidocRender

extension Unidoc
{
    public final
    class Server:Sendable
    {
        public
        let context:ServerPluginContext
        public
        let plugins:[String: any ServerPlugin]
        @usableFromInline
        let options:ServerOptions
        public
        let db:Database

        private
        let updateQueue:AsyncStream<Update>.Continuation,
            updates:AsyncStream<Update>

        let builds:BuildCoordinator?

        let policy:(any HTTP.ServerPolicy)?
        @usableFromInline
        let logger:(any ServerLogger)?

        public
        init(
            plugins:[any ServerPlugin],
            context:ServerPluginContext,
            options:ServerOptions,
            builds:BuildCoordinator?,
            logger:(any ServerLogger)? = nil,
            db:Database)
        {
            var policy:(any HTTP.ServerPolicy)? = nil

            for case let plugin as any HTTP.ServerPolicy in plugins
            {
                policy = plugin
                break
            }

            self.plugins = plugins.reduce(into: [:]) { $0[$1.id] = $1 }
            self.context = context
            self.options = options
            self.builds = builds
            self.policy = policy
            self.logger = logger
            self.db = db

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

    var format:Unidoc.RenderFormat
    {
        self.format(username: nil, locale: nil)
    }

    private
    func format(for request:Unidoc.IncomingRequest) -> Unidoc.RenderFormat
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

        return self.format(username: username, locale: request.origin.guess?.locale)
    }

    private
    func format(username:String?, locale:ISO.Locale?) -> Unidoc.RenderFormat
    {
        .init(
            security: self.db.policy.security,
            username: username,
            locale: locale ?? .init(language: .en),
            assets: self.options.cloudfront ? .cloudfront : .local,
            server: self.options.mode.server)
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

        //  Create the machine user, if it doesn’t exist. Don’t store the cookie, since we
        //  want to be able to change it without restarting the server.
        let _:Unidoc.UserSecrets = try await db.users.update(user: .init(machine: 0))
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
}
extension Unidoc.Server
{
    private
    func clearance(by authorization:Unidoc.Authorization) async throws -> HTTP.ServerResponse?
    {
        guard case .production = self.options.mode
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
    func clearance(for request:Unidoc.StreamedRequest) async throws -> HTTP.ServerResponse?
    {
        try await self.clearance(by: request.authorization)
    }

    public
    func response(for request:Unidoc.StreamedRequest,
        with body:__owned [UInt8]) async -> HTTP.ServerResponse
    {
        await self.submit(update: request.endpoint, with: body)
    }

    public
    func response(for request:Unidoc.IntegralRequest) async throws -> HTTP.ServerResponse
    {
        switch request.assignee
        {
        case .unordered(let operation):
            return try await self.respond(to: request.incoming, running: operation)

        case .update(let procedural):
            if  let failure:HTTP.ServerResponse = try await self.clearance(
                    by: request.incoming.authorization)
            {
                return failure
            }

            return await self.submit(update: procedural)

        case .sync(let response):
            self.logger?.log(request: request.incoming, with: response, time: .zero)
            return response

        case .syncHTML(let renderable):
            let response:HTTP.ServerResponse = renderable.response(
                format: self.format(for: request.incoming))

            self.logger?.log(request: request.incoming, with: response, time: .zero)
            return response

        case .syncLoad(let request):
            guard case .development(let cache, _) = self.options.mode
            else
            {
                //  In production mode, static assets are served by Cloudfront.
                return .forbidden("")
            }

            return try await cache.serve(request)
        }
    }
}
extension Unidoc.Server
{
    private
    func submit(update operation:any Unidoc.ProceduralOperation,
        with body:__owned [UInt8] = []) async -> HTTP.ServerResponse
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
    func respond(to request:Unidoc.IncomingRequest,
        running operation:any Unidoc.InteractiveOperation) async throws -> HTTP.ServerResponse
    {
        try Task.checkCancellation()

        do
        {
            let initiated:ContinuousClock.Instant = .now
            let format:Unidoc.RenderFormat = self.format(for: request)
            let state:Unidoc.UserSessionState = .init(authorization: request.authorization,
                request: request.uri,
                format: format)

            let response:HTTP.ServerResponse = try await operation.load(from: self, with: state)
                ?? .notFound("not found\n")

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

            self.logger?.log(request: request, with: response, time: .now - initiated)
            return response
        }
        catch let error as CancellationError
        {
            throw error
        }
        catch let error
        {
            self.logger?.log(request: request, with: error)

            let page:Unidoc.ServerErrorPage = .init(error: error)
            return .error(page.resource(format: self.format(for: request)))
        }
    }
}
