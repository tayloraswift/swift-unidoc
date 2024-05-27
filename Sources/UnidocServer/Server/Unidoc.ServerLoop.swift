import GitHubAPI
import HTTP
import HTTPServer
import MongoDB
import UnidocProfiling
import UnidocRender

extension Unidoc
{
    public final
    actor ServerLoop
    {
        public nonisolated
        let context:ServerPluginContext
        public nonisolated
        let plugins:[String: any ServerPlugin]
        @usableFromInline nonisolated
        let options:ServerOptions
        public nonisolated
        let db:Database

        private nonisolated
        let updateQueue:AsyncStream<Update>.Continuation,
            updates:AsyncStream<Update>

        private nonisolated
        let graphState:GraphStateLoop

        nonisolated
        let policy:(any HTTP.ServerPolicy)?

        var tour:ServerTour

        public
        init(
            plugins:[any ServerPlugin],
            context:ServerPluginContext,
            options:ServerOptions,
            graphState:GraphStateLoop,
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
            self.graphState = graphState
            self.policy = policy
            self.db = db

            self.tour = .init()

            (self.updates, self.updateQueue) = AsyncStream<Update>.makeStream(
                bufferingPolicy: .bufferingOldest(16))
        }
    }
}
extension Unidoc.ServerLoop
{
    @inlinable public nonisolated
    var secure:Bool
    {
        switch self.options.mode
        {
        case .development: false
        case .production:  true
        }
    }

    @inlinable public nonisolated
    var github:GitHub.Integration? { self.options.github }
    @inlinable public nonisolated
    var bucket:Unidoc.Buckets { self.options.bucket }

    @inlinable public nonisolated
    var format:Unidoc.RenderFormat
    {
        self.format(locale: nil)
    }

    @inlinable nonisolated
    func format(locale:HTTP.Locale?) -> Unidoc.RenderFormat
    {
        .init(
            assets: self.options.cloudfront ? .cloudfront : .local,
            locale: locale,
            server: self.options.mode.server)
    }
}
extension Unidoc.ServerLoop
{
    //  TODO: this really should be manually-triggered and should not run every time.
    nonisolated
    func _setup() async throws
    {
        let session:Mongo.Session = try await .init(from: self.db.sessions)

        //  Create the machine user, if it doesn’t exist. Don’t store the cookie, since we
        //  want to be able to change it without restarting the server.
        let _:Unidoc.UserSecrets = try await self.db.users.update(user: .machine(0),
            with: session)
    }

    nonisolated
    func update() async throws
    {
        for await update:Update in self.updates
        {
            try Task.checkCancellation()

            let promise:Promise = update.promise
            let payload:[UInt8] = update.payload

            await (/* consume */ update).operation.perform(on: self,
                payload: payload,
                request: promise)
        }
    }
}
extension Unidoc.ServerLoop
{
    private nonisolated
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

        let session:Mongo.Session = try await .init(from: self.db.sessions)

        guard
        let rights:Unidoc.UserRights = try await self.db.users.validate(user: user,
            with: session)
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

extension Unidoc.ServerLoop
{
    public nonisolated
    func clearance(for request:Unidoc.StreamedRequest) async throws -> HTTP.ServerResponse?
    {
        try await self.clearance(by: request.authorization)
    }

    public nonisolated
    func response(for request:Unidoc.StreamedRequest,
        with body:__owned [UInt8]) async -> HTTP.ServerResponse
    {
        await self.submit(update: request.endpoint, with: body)
    }

    public nonisolated
    func response(for request:Unidoc.IntegralRequest) async throws -> HTTP.ServerResponse
    {
        switch request.assignee
        {
        case .actor(let operation):
            return try await self.respond(to: request.incoming, running: operation)

        case .update(let procedural):
            if  let failure:HTTP.ServerResponse = try await self.clearance(
                    by: request.incoming.authorization)
            {
                return failure
            }

            return await self.submit(update: procedural)

        case .syncError(let message):
            return .resource(.init(content: .init(
                    body: .string(message),
                    type: .text(.plain, charset: .utf8))),
                status: 400)

        case .syncResource(let renderable):
            return .ok(renderable.resource(format: self.format))

        case .syncRedirect(let target):
            return .redirect(target)

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
extension Unidoc.ServerLoop
{
    private nonisolated
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
        let response:HTTP.ServerResponse
        let duration:Duration

        do
        {
            try Task.checkCancellation()

            let initiated:ContinuousClock.Instant = .now

            response = try await operation.load(
                from: .init(self, tour: self.tour),
                with: .init(authorization: request.authorization, request: request.uri),
                as: self.format(locale: request.origin.guess?.locale)) ?? .notFound("not found")

            duration = .now - initiated
        }
        catch let error as CancellationError
        {
            throw error
        }
        catch let error
        {
            self.tour.errors += 1

            Log[.error] = "\(error)"
            Log[.error] = "request = \(request.uri)"

            let page:Unidoc.ServerErrorPage = .init(error: error)
            return .error(page.resource(format: self.format))
        }

        //  Don’t count login requests.
        if  operation is Unidoc.LoadDashboardOperation ||
            operation is Unidoc.LoginOperation ||
            operation is Unidoc.AuthOperation ||
            operation is Unidoc.UserConfigOperation
        {
            return response
        }
        //  Don’t increment stats from administrators,
        //  they will really skew the results.
        if  case .web(_?, _) = request.authorization
        {
            return response
        }

        if  self.tour.slowestQuery?.time ?? .zero < duration
        {
            self.tour.slowestQuery = .init(time: duration, uri: request.uri)
        }
        if  duration > .seconds(1)
        {
            Log[.warning] = """
            query '\(request.uri)' took \(duration) to complete!
            """
        }

        if  case .barbie(let locale)? = request.origin.guess
        {
            self.tour.metrics.languages[locale.language] += 1
        }

        let origin:Unidoc.ServerMetrics.Origin = .of(request)
        let crosstab:Unidoc.ServerMetrics.Crosstab = origin.crosstab

        self.tour.metrics.transfer[origin] += response.size
        self.tour.metrics.requests[origin] += 1

        self.tour.metrics.protocols[crosstab, default: [:]][.init(http: request.version)] += 1
        self.tour.metrics.responses[crosstab, default: [:]][.of(response)] += 1
        self.tour.last[crosstab] = request.logged

        return response
    }
}
