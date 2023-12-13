import Atomics
import HTTP
import HTTPClient
import HTTPServer
import IP
import MongoDB
import NIOCore
import NIOPosix
import NIOHTTP1
import NIOSSL
import UnidocDB
import UnidocPages
import UnidocProfiling
import UnidocQueries
import UnidocRecords

extension Swiftinit
{
    final
    actor ServerLoop
    {
        nonisolated
        let atomics:Counters
        nonisolated
        let plugins:Plugins
        nonisolated
        let db:DB

        private nonisolated
        let updater:AsyncStream<Update>.Continuation,
            updates:AsyncStream<Update>

        private nonisolated
        let options:Options
        private
        var tour:ServerTour

        init(options:Options, plugins:Plugins, db:DB)
        {
            self.atomics = .init()
            self.plugins = plugins
            self.db = db

            var continuation:AsyncStream<Update>.Continuation? = nil
            self.updates = .init(bufferingPolicy: .bufferingOldest(16))
            {
                continuation = $0
            }
            self.updater = continuation!

            self.options = options
            self.tour = .init()
        }
    }
}
extension Swiftinit.ServerLoop
{
    init(
        options:Swiftinit.Options,
        threads:MultiThreadedEventLoopGroup,
        mongodb:Mongo.SessionPool) async throws
    {
        let policy:PolicyPlugin? = options.whitelists ? .init() : nil
        let github:GitHubPlugin? = options.secrets.github.map
        {
            do
            {
                return try .load(secrets: $0)
            }
            catch
            {
                Log[.debug] = "App secret unavailable, GitHub integration has been disabled!"
                return nil
            }
        } ?? nil

        var configuration:TLSConfiguration = .makeClientConfiguration()
            configuration.applicationProtocols = ["h2"]

        self.init(
            options: options,
            plugins: .init(list: .init(
                    policy: policy,
                    github: github),
                threads: threads,
                niossl: try .init(configuration: configuration)),
            db: .init(sessions: mongodb,
                unidoc: await .setup(as: "unidoc", in: mongodb)))
    }
}

extension Swiftinit.ServerLoop
{
    nonisolated
    var secured:Bool { self.options.mode.secured }

    nonisolated
    var assets:StaticAssets { self.options.cloudfront ? .cloudfront : .local }
}

extension Swiftinit.ServerLoop
{
    nonisolated
    func run() async throws
    {
        let session:Mongo.Session = try await .init(from: self.db.sessions)

        //  Create the machine user, if it doesn’t exist. Don’t store the cookie, since we
        //  want to be able to change it without restarting the server.
        let _:Unidex.Cookie = try await self.db.users.update(user: .machine(0),
            with: session)

        _ = consume session

        try await withThrowingTaskGroup(of: Void.self)
        {
            (tasks:inout ThrowingTaskGroup<Void, any Error>) in

            let policies:ManagedAtomic<HTTP.Policylist> = .init(.init(v4: [], v6: []))

            tasks.addTask
            {
                try await self.serve(from: ("::", self.options.port),
                    as: self.options.authority,
                    on: self.plugins.threads,
                    policylist: policies)
            }
            tasks.addTask
            {
                try await self.update()
            }

            if  let plugin:Swiftinit.PluginIntegration<PolicyPlugin> = self.plugins.policy
            {
                tasks.addTask
                {
                    try await plugin.crawler.run(alongside: self, updating: policies)
                }
            }
            if  let plugin:Swiftinit.PluginIntegration<GitHubPlugin> = self.plugins.github
            {
                tasks.addTask
                {
                    try await plugin.crawler.run(alongside: self)
                }
            }

            for try await _:Void in tasks
            {
                tasks.cancelAll()
            }
        }
    }
}
extension Swiftinit.ServerLoop
{
    private nonisolated
    func clearance(by cookies:Swiftinit.Cookies) async throws -> HTTP.ServerResponse?
    {
        guard self.secured
        else
        {
            return nil
        }

        guard
        let cookie:Unidex.Cookie = cookies.session
        else
        {
            return .unauthorized("")
        }

        let session:Mongo.Session = try await .init(from: self.db.sessions)

        switch try await self.db.users.validate(cookie: cookie, with: session)
        {
        case (_, .administratrix)?: return nil
        case (_, .machine)?:        return nil
        default:                    return .forbidden("")
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
        with body:[UInt8]) async throws -> HTTP.ServerResponse
    {
        guard case .procedural(let procedural) = request.endpoint
        else
        {
            return .notFound("")
        }

        return try await withCheckedThrowingContinuation
        {
            guard case .enqueued = self.updater.yield(.init(endpoint: procedural,
                payload: body,
                promise: $0))
            else
            {
                fatalError("unimplemented")
            }
        }
    }

    nonisolated
    func response(for request:Swiftinit.IntegralRequest) async throws -> HTTP.ServerResponse
    {
        switch request.endpoint
        {
        case .interactive(let endpoint):
            return try await self.response(endpoint: endpoint, metadata: request.metadata)

        case .procedural(let procedural):
            if  let failure:HTTP.ServerResponse = try await self.clearance(
                    by: request.metadata.cookies)
            {
                return failure
            }
            return try await withCheckedThrowingContinuation
            {
                Log[.debug] = "enqueued procedural request"

                guard case .enqueued = self.updater.yield(.init(endpoint: procedural,
                    payload: [],
                    promise: $0))
                else
                {
                    fatalError("unimplemented")
                }
            }

        case .stateless(let stateless):
            return .ok(stateless.resource(assets: self.assets))

        case .redirect(let target):
            return .redirect(.permanent(target))

        case .static(let request):
            if  case .development(let cache, _) = self.options.mode
            {
                return try await cache.serve(request)
            }
            else
            {
                //  In production mode, static assets are served by Cloudfront.
                return .forbidden("")
            }
        }
    }
}
extension Swiftinit.ServerLoop
{
    private
    func response(
        endpoint:any InteractiveEndpoint,
        metadata:Swiftinit.IntegralRequest.Metadata) async throws -> HTTP.ServerResponse
    {
        try Task.checkCancellation()

        let initiated:ContinuousClock.Instant = .now

        let response:HTTP.ServerResponse = try await endpoint.load(
            from: .init(self, tour: self.tour),
            with: metadata.cookies)
            ?? .notFound(.init(
                content: .string("not found"),
                type: .text(.plain, charset: .utf8)))

        let duration:Duration = .now - initiated

        //  Don’t count login requests.
        if  endpoint is Swiftinit.BounceEndpoint ||
            endpoint is Swiftinit.LoginEndpoint ||
            endpoint is Swiftinit.AdminDashboardEndpoint
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
        case    .barbie(let language):
            self.tour.profile.responses.toBarbie[keyPath: status] += 1
            self.tour.profile.languages[language.dominant] += 1

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

    private
    func update() async throws
    {
        for await update:Update in self.updates
        {
            try Task.checkCancellation()

            let promise:CheckedContinuation<HTTP.ServerResponse, any Error> = update.promise
            let payload:[UInt8] = update.payload

            await (consume update).endpoint.perform(on: .init(self, tour: self.tour),
                payload: payload,
                request: promise)
        }
    }
}
