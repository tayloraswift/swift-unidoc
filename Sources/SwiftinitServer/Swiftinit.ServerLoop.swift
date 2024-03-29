import Atomics
import GitHubAPI
import HTTP
import HTTPClient
import HTTPServer
import IP
import Media
import MongoDB
import NIOCore
import NIOHTTP1
import NIOPosix
import NIOSSL
import S3
import SwiftinitPages
import SwiftinitPlugins
import UnidocDB
import UnidocProfiling
import UnidocQueries
import UnidocRecords

extension Swiftinit
{
    final
    actor ServerLoop
    {
        nonisolated
        let context:ServerPluginContext
        nonisolated
        let plugins:[String: any Swiftinit.ServerPlugin]
        private nonisolated
        let options:ServerOptions
        nonisolated
        let db:DB

        private nonisolated
        let updateQueue:AsyncStream<Update>.Continuation,
            updates:AsyncStream<Update>

        private
        var tour:ServerTour

        init(
            plugins:[String: any Swiftinit.ServerPlugin],
            context:ServerPluginContext,
            options:ServerOptions,
            db:DB)
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
extension Swiftinit.ServerLoop
{
    init(
        context:Swiftinit.ServerPluginContext,
        options:Swiftinit.ServerOptions,
        mongodb:Mongo.SessionPool) async throws
    {
        self.init(
            plugins: options.plugins.reduce(into: [:]) { $0[$1.id] = $1 },
            context: context,
            options: options,
            db: .init(sessions: mongodb,
                unidoc: await .setup(as: "unidoc", in: mongodb))
            {
                //  200 API calls per hour.
                $0.apiLimitInterval = .seconds(3600)
                $0.apiLimitPerReset = 200
            })
    }
}

extension Swiftinit.ServerLoop
{
    nonisolated
    var secure:Bool
    {
        switch self.options.mode
        {
        case .development: false
        case .production:  true
        }
    }

    nonisolated
    var github:GitHub.Integration? { self.options.github }
    nonisolated
    var bucket:AWS.S3.Bucket? { self.options.bucket }

    nonisolated
    var format:Swiftinit.RenderFormat
    {
        self.format(locale: nil)
    }

    nonisolated private
    func format(locale:HTTP.Locale?) -> Swiftinit.RenderFormat
    {
        .init(
            assets: self.options.cloudfront ? .cloudfront : .local,
            locale: locale,
            server: self.options.mode.server)
    }
}

extension Swiftinit.ServerLoop
{
    nonisolated
    func run() async throws
    {
        let session:Mongo.Session = try await .init(from: self.db.sessions)

        //  Create the machine user, if it doesn’t exist. Don’t store the cookie, since we
        //  want to be able to change it without restarting the server.
        let _:Unidoc.UserSecrets = try await self.db.users.update(user: .machine(0),
            with: session)

        _ = consume session

        try await withThrowingTaskGroup(of: Void.self)
        {
            (tasks:inout ThrowingTaskGroup<Void, any Error>) in

            var policy:Swiftinit.PolicyPlugin? = nil
            for plugin:any Swiftinit.ServerPlugin in self.plugins.values
            {
                if  case let plugin as Swiftinit.PolicyPlugin = plugin
                {
                    policy = plugin
                }

                tasks.addTask
                {
                    try await plugin.run(in: self.context, with: self.db)
                }
            }
            do
            {
                let policy:Swiftinit.PolicyPlugin? = consume policy

                tasks.addTask
                {
                    try await self.serve(from: ("::", self.options.port),
                        as: self.options.authority,
                        on: self.context.threads,
                        policy: policy)
                }
                tasks.addTask
                {
                    try await self.update()
                }
            }

            for try await _:Void in tasks
            {
                tasks.cancelAll()
            }
        }
    }

    private
    func update() async throws
    {
        for await update:Update in self.updates
        {
            try Task.checkCancellation()

            let promise:Promise = update.promise
            let payload:[UInt8] = update.payload

            await (consume update).endpoint.perform(on: .init(self, tour: self.tour),
                payload: payload,
                request: promise)
        }
    }
}
extension Swiftinit.ServerLoop
{
    private nonisolated
    func clearance(by cookies:Swiftinit.Cookies) async throws -> HTTP.ServerResponse?
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

extension Swiftinit.ServerLoop:HTTP.ServerLoop
{
    nonisolated
    func clearance(for request:Swiftinit.StreamedRequest) async throws -> HTTP.ServerResponse?
    {
        try await self.clearance(by: request.cookies)
    }

    nonisolated
    func response(for request:Swiftinit.StreamedRequest,
        with body:consuming [UInt8]) async -> HTTP.ServerResponse
    {
        await self.submit(update: request.endpoint, with: body)
    }

    nonisolated
    func response(for request:Swiftinit.IntegralRequest) async throws -> HTTP.ServerResponse
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
extension Swiftinit.ServerLoop
{
    private nonisolated
    func submit(update endpoint:any Swiftinit.ProceduralEndpoint,
        with body:consuming [UInt8] = []) async -> HTTP.ServerResponse
    {
        await withCheckedContinuation
        {
            guard case .enqueued = self.updateQueue.yield(.init(endpoint: endpoint,
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
        metadata:Swiftinit.IntegralRequest.Metadata,
        endpoint:any Swiftinit.InteractiveEndpoint) async throws -> HTTP.ServerResponse
    {
        let response:HTTP.ServerResponse
        let duration:Duration

        do
        {
            try Task.checkCancellation()

            let initiated:ContinuousClock.Instant = .now

            response = try await endpoint.load(
                from: .init(self, tour: self.tour),
                with: metadata.cookies,
                as: self.format(locale: metadata.annotation.locale))
                ?? .notFound(.init(
                    content: .string("not found"),
                    type: .text(.plain, charset: .utf8),
                    gzip: false))

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

            let page:Swiftinit.ServerErrorPage = .init(error: error)
            return .error(page.resource(format: self.format))
        }

        //  Don’t count login requests.
        if  endpoint is Swiftinit.DashboardEndpoint ||
            endpoint is Swiftinit.LoginEndpoint ||
            endpoint is Swiftinit.AuthEndpoint ||
            endpoint is Swiftinit.UserConfigEndpoint
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
