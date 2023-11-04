import HTTP
import HTTPClient
import HTTPServer
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

@dynamicMemberLookup
final
actor Server
{
    private nonisolated
    let updater:AsyncStream<Update>.Continuation,
        updates:AsyncStream<Update>

    private nonisolated
    let options:Options
    nonisolated
    let plugins:Plugins
    nonisolated
    let count:Counters

    var tour:ServerTour

    nonisolated
    let db:DB

    private
    init(options:Options, plugins:Plugins, db:DB)
    {
        var continuation:AsyncStream<Update>.Continuation? = nil
        self.updates = .init(bufferingPolicy: .bufferingOldest(16))
        {
            continuation = $0
        }
        self.updater = continuation!

        self.options = options
        self.plugins = plugins

        self.count = .init()
        self.tour = .init()

        self.db = db
    }
}
extension Server
{
    init(
        options:Options,
        threads:MultiThreadedEventLoopGroup,
        mongodb:Mongo.SessionPool) async throws
    {
        let whitelist:WhitelistPlugin? = options.whitelists ? .init() : nil
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
            plugins: .init(
                threads: threads,
                niossl: try .init(configuration: configuration),
                whitelist: whitelist,
                github: github),
            db: .init(sessions: mongodb,
                account: await .setup(as: "accounts", in: mongodb),
                unidoc: await .setup(as: "unidoc", in: mongodb)))
    }
}
extension Server
{
    nonisolated
    var secured:Bool { self.options.mode.secured }

    nonisolated
    var assets:StaticAssets
    {
        guard self.options.cloudfront
        else
        {
            return .init(version: nil)
        }

        //  Eventually, this should be dynamically configurable. But for now, we just
        //  hard-code the version number.
        return .init(version: .v(1, 2))
    }

    nonisolated
    subscript<Plugin>(
        dynamicMember keyPath:KeyPath<Plugins, Plugin?>) -> PluginIntegration<Plugin>?
    {
        self.plugins[keyPath: keyPath].map
        {
            .init(threads: self.plugins.threads, niossl: self.plugins.niossl, plugin: $0)
        }
    }
}

extension Server
{
    nonisolated
    func run() async throws
    {
        let session:Mongo.Session = try await .init(from: self.db.sessions)

        //  Create the machine user, if it doesn’t exist. Don’t store the cookie, since we
        //  want to be able to change it without restarting the server.
        let _:Account.Cookie = try await self.db.account.users.update(
            account: .machine(0),
            with: session)

        _ = consume session

        try await withThrowingTaskGroup(of: Void.self)
        {
            (tasks:inout ThrowingTaskGroup<Void, any Error>) in

            tasks.addTask
            {
                try await self.serve(from: ("::", self.options.port),
                    as: self.options.authority,
                    on: self.plugins.threads)
            }
            tasks.addTask
            {
                try await self.update()
            }

            if  let plugin:PluginIntegration<GitHubPlugin> = self.github
            {
                tasks.addTask
                {
                    try await plugin.crawler(db: self.db).run(counters: self.count)
                }
            }
            if  let plugin:PluginIntegration<WhitelistPlugin> = self.whitelist
            {
                tasks.addTask
                {
                    try await plugin.crawler.run(counters: self.count)
                }
            }

            for try await _:Void in tasks
            {
                tasks.cancelAll()
            }
        }
    }
}
extension Server
{
    nonisolated
    func clearance(by cookies:Cookies) async throws -> HTTP.ServerResponse?
    {
        guard self.secured
        else
        {
            return nil
        }

        guard
        let cookie:Account.Cookie = cookies.session
        else
        {
            return .unauthorized("")
        }

        let mongo:Mongo.Session = try await .init(from: self.db.sessions)

        switch try await self.db.account.users.validate(cookie: cookie, with: mongo)
        {
        case .administrator?, .machine?:
            return nil

        case .human?, nil:
            return .forbidden("")
        }
    }
}
extension Server:HTTP.Server
{
    nonisolated
    func clearance(for request:StreamedRequest) async throws -> HTTP.ServerResponse?
    {
        try await self.clearance(by: request.cookies)
    }

    nonisolated
    func response(for request:StreamedRequest,
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
    func response(for request:IntegralRequest) async throws -> HTTP.ServerResponse
    {
        switch request.endpoint
        {
        case .interactive(let endpoint):
            return try await self.response(endpoint: endpoint,
                cookies: request.cookies,
                profile: request.profile)

        case .procedural(let procedural):
            if  let failure:HTTP.ServerResponse = try await self.clearance(by: request.cookies)
            {
                return failure
            }
            return try await withCheckedThrowingContinuation
            {
                Log[.debug] = "enqueued request via \(request.profile.uri)"

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
extension Server
{
    private
    func response(endpoint:any InteractiveEndpoint,
        cookies:Cookies,
        profile:ServerProfile.Sample) async throws -> HTTP.ServerResponse
    {
        try Task.checkCancellation()

        let initiated:ContinuousClock.Instant = .now

        let response:HTTP.ServerResponse = try await endpoint.load(from: self, with: cookies)
            ?? .notFound(.init(
                content: .string("not found"),
                type: .text(.plain, charset: .utf8)))

        let duration:Duration = .now - initiated

        //  Don’t count login requests.
        if  endpoint is Server.Endpoint.Login
        {
            return response
        }
        //  Don’t increment stats from administrators,
        //  they will really skew the results.
        if  case _? = cookies.session
        {
            return response
        }

        if  self.tour.slowestQuery?.duration ?? .zero < duration
        {
            self.tour.slowestQuery = .init(
                duration: duration,
                uri: profile.uri)
        }
        if  duration > .seconds(1)
        {
            Log[.warning] = """
            query '\(profile.uri)' took \(duration) to complete!
            """
        }

        let status:WritableKeyPath<ServerProfile.ByStatus, Int> = response.category
        let agent:WritableKeyPath<ServerProfile.ByAgent, Int> = profile._agent
        let http:WritableKeyPath<ServerProfile.ByProtocol, Int> = profile.http2 ?
            \.http2 :
            \.http1

        self.tour.profile.requests.bytes[keyPath: agent] += response.size
        self.tour.profile.requests.pages[keyPath: agent] += 1

        switch agent
        {
        case    \.likelyBarbie:
            //  Only count languages for Barbies.
            self.tour.profile.languages[keyPath: profile._language] += 1
            self.tour.profile.responses.toBarbie[keyPath: status] += 1
            self.tour.profile.protocols.toBarbie[keyPath: http] += 1

            self.tour.lastImpression = profile

        case    \.likelyBratz:
            self.tour.profile.responses.toBratz[keyPath: status] += 1
            self.tour.profile.protocols.toBratz[keyPath: http] += 1

        case    \.likelyGooglebot,
                \.likelyMajorSearchEngine,
                \.likelyMinorSearchEngine:
            self.tour.profile.responses.toSearch[keyPath: status] += 1
            self.tour.profile.protocols.toSearch[keyPath: http] += 1

        case    _:
            self.tour.profile.responses.toOther[keyPath: status] += 1
            self.tour.profile.protocols.toOther[keyPath: http] += 1
        }

        self.tour.last = profile

        return response
    }

    private
    func update() async throws
    {
        for await update:Update in self.updates
        {
            try Task.checkCancellation()

            do
            {
                update.promise.resume(returning: try await update.endpoint.perform(on: self,
                    with: update.payload))
            }
            catch let error
            {
                update.promise.resume(throwing: error)
            }
        }
    }
}
