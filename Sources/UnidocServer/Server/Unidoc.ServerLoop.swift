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

        public
        var tour:ServerTour

        public
        init(
            plugins:[String: any ServerPlugin],
            context:ServerPluginContext,
            options:ServerOptions,
            db:Database)
        {
            self.plugins = plugins
            self.context = context
            self.options = options
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
    var authority:any ServerAuthority { self.options.authority }

    @inlinable public nonisolated
    var port:Int { self.options.port }

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
    public
    func update() async throws
    {
        for await update:Update in self.updates
        {
            try Task.checkCancellation()

            let promise:Promise = update.promise
            let payload:[UInt8] = update.payload

            await (/* consume */ update).operation.perform(on: .init(self, tour: self.tour),
                payload: payload,
                request: promise)
        }
    }
}
extension Unidoc.ServerLoop
{
    private nonisolated
    func clearance(by cookies:Unidoc.Cookies) async throws -> HTTP.ServerResponse?
    {
        guard case .production = self.options.mode
        else
        {
            return nil
        }

        guard
        let user:Unidoc.UserSession = cookies.session
        else
        {
            return .unauthorized("")
        }

        let session:Mongo.Session = try await .init(from: self.db.sessions)

        guard
        let level:Unidoc.User.Level = try await self.db.users.validate(user: user,
            with: session)
        else
        {
            return .notFound("No such user")
        }

        switch level
        {
        case .administratrix:   return nil
        case .machine:          return nil
        case .human:            return .forbidden("")
        }
    }
}

extension Unidoc.ServerLoop
{
    public nonisolated
    func clearance(for request:Unidoc.StreamedRequest) async throws -> HTTP.ServerResponse?
    {
        try await self.clearance(by: request.cookies)
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
        switch request.ordering
        {
        case .actor(let interactive):
            return try await self.response(metadata: request.metadata, endpoint: interactive)

        case .update(let procedural):
            if  let failure:HTTP.ServerResponse = try await self.clearance(
                    by: request.metadata.cookies)
            {
                return failure
            }

            return await self.submit(update: procedural)

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
    func response(
        metadata:Unidoc.IntegralRequest.Metadata,
        endpoint:any Unidoc.InteractiveOperation) async throws -> HTTP.ServerResponse
    {
        let response:HTTP.ServerResponse
        let duration:Duration

        do
        {
            try Task.checkCancellation()

            let initiated:ContinuousClock.Instant = .now

            response = try await endpoint.load(
                from: .init(self, tour: self.tour),
                with: metadata.credentials,
                as: self.format(locale: metadata.annotation.locale)) ?? .notFound("not found")

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
            Log[.error] = "request = \(metadata.path)"

            let page:Unidoc.ServerErrorPage = .init(error: error)
            return .error(page.resource(format: self.format))
        }

        //  Don’t count login requests.
        if  endpoint is Unidoc.LoadDashboardOperation ||
            endpoint is Unidoc.LoginOperation ||
            endpoint is Unidoc.AuthOperation ||
            endpoint is Unidoc.UserConfigOperation
        {
            return response
        }
        //  Don’t increment stats from administrators,
        //  they will really skew the results.
        if  case _? = metadata.cookies.session
        {
            return response
        }

        if  self.tour.slowestQuery?.time ?? .zero < duration
        {
            self.tour.slowestQuery = .init(time: duration, path: metadata.path)
        }
        if  duration > .seconds(1)
        {
            Log[.warning] = """
            query '\(metadata.path)' took \(duration) to complete!
            """
        }

        let status:WritableKeyPath<ServerProfile.ByStatus, Int> = response.category
        switch metadata.version
        {
        case .http2:    self.tour.profile.requests.http2[metadata.annotation] += 1
        case .http1_1:  self.tour.profile.requests.http1[metadata.annotation] += 1
        }

        self.tour.profile.requests.bytes[metadata.annotation] += response.size

        switch metadata.annotation
        {
        case    .barbie(let locale):
            self.tour.profile.responses.toBarbie[keyPath: status] += 1
            self.tour.profile.languages[locale.language] += 1

            self.tour.lastImpression = metadata.logged

        case    .bratz:
            self.tour.profile.responses.toBratz[keyPath: status] += 1

        case    .robot(.googlebot):
            self.tour.profile.responses.toGooglebot[keyPath: status] += 1
            self.tour.lastSearchbot = metadata.logged

        case    .robot(.bingbot):
            self.tour.profile.responses.toBingbot[keyPath: status] += 1
            self.tour.lastSearchbot = metadata.logged

        case    .robot(.amazonbot),
                .robot(.baiduspider),
                .robot(.duckduckbot),
                .robot(.quant),
                .robot(.naver),
                .robot(.petal),
                .robot(.seznam),
                .robot(.yandexbot):
            self.tour.profile.responses.toOtherSearch[keyPath: status] += 1
            self.tour.lastSearchbot = metadata.logged

        case    _:
            self.tour.profile.responses.toOtherRobots[keyPath: status] += 1
        }

        self.tour.lastRequest = metadata.logged

        return response
    }
}
