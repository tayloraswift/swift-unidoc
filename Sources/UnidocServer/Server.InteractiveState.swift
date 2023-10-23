import Atomics
import GitHubClient
import GitHubAPI
import HTTP
import HTTPServer
import UnidocPages
import UnidocProfiling

extension Server
{
    @dynamicMemberLookup
    struct InteractiveState
    {
        private
        let server:Server
        let github:GitHubPlugin.Partner?

        var tour:ServerTour

        init(server:Server, github:GitHubPlugin.Partner?)
        {
            self.server = server
            self.github = github
            self.tour = .init()
        }
    }
}
extension Server.InteractiveState
{
    subscript<T>(dynamicMember keyPath:KeyPath<Server, T>) -> T
    {
        self.server[keyPath: keyPath]
    }
}
extension Server.InteractiveState
{
    mutating
    func respond(to requests:AsyncStream<Server.Request<any InteractiveEndpoint>>) async throws
    {
        for await request:Server.Request<any InteractiveEndpoint> in requests
        {
            try Task.checkCancellation()

            let response:ServerResponse
            let duration:Duration

            do
            {
                let initiated:ContinuousClock.Instant = .now

                response = try await request.endpoint.load(
                    from: self,
                    with: request.cookies)
                    ?? .notFound(.init(
                        content: .string("not found"),
                        type: .text(.plain, charset: .utf8)))

                let finished:ContinuousClock.Instant = .now

                duration = finished - initiated
            }
            catch let error
            {
                request.promise.fail(error)
                continue
            }
            defer
            {
                request.promise.succeed(response)
            }

            //  Don’t count login requests.
            if  request.endpoint is Server.Endpoint.Login
            {
                continue
            }
            //  Don’t increment stats from administrators,
            //  they will really skew the results.
            if  case _? = request.cookies.session
            {
                continue
            }

            if  self.tour.slowestQuery?.duration ?? .zero < duration,
                let uri:String = request.profile.uri
            {
                self.tour.slowestQuery = .init(
                    duration: duration,
                    uri: uri)
            }
            if  duration > .seconds(1)
            {
                Log[.warning] = """
                query '\(request.profile.uri ?? "")' took \(duration) to complete!
                """
            }

            let status:WritableKeyPath<ServerProfile.ByStatus, Int> = response.category
            let agent:WritableKeyPath<ServerProfile.ByAgent, Int> = request.agent

            self.tour.profile.requests.bytes[keyPath: agent] += response.size
            self.tour.profile.requests.pages[keyPath: agent] += 1

            switch agent
            {
            case    \.likelyBarbie:
                //  Only count languages for Barbies.
                self.tour.profile.languages[keyPath: request.language] += 1
                self.tour.profile.responses.toBarbie[keyPath: status] += 1

                self.tour.lastImpression = request.profile

            case    \.likelyBratz:
                self.tour.profile.responses.toBratz[keyPath: status] += 1

            case    \.likelyGooglebot,
                    \.likelyMajorSearchEngine,
                    \.likelyMinorSearchEngine:
                self.tour.profile.responses.toSearch[keyPath: status] += 1

            case    _:
                self.tour.profile.responses.toOther[keyPath: status] += 1
            }

            self.tour.last = request.profile
        }
    }
}
extension Server.InteractiveState
{
    /// TODO: make this configurable.
    var robots:String
    {
        """
        User-agent: mauibot
        Crawl-delay: 20


        User-agent: semrushbot
        Crawl-delay: 20


        User-agent: ahrefsbot
        Crawl-delay: 20


        User-agent: blexbot
        Crawl-delay: 20


        User-agent: seo spider
        Crawl-delay: 20


        User-agent: MJ12bot
        Crawl-delay: 20


        User-agent: Bytespider
        Crawl-delay: 10


        User-agent: *
        Disallow: /admin/
        Disallow: /auth/

        """
    }
}
