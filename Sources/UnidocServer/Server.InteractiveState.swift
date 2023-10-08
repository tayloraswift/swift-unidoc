import GitHubClient
import GitHubAPI
import HTTP
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

            do
            {
                let initiated:ContinuousClock.Instant = .now

                let response:ServerResponse = try await request.endpoint.load(
                    from: self,
                    with: request.cookies)
                    ?? .notFound(.init(
                        content: .string("not found"),
                        type: .text(.plain, charset: .utf8)))

                let finished:ContinuousClock.Instant = .now
                let duration:Duration = finished - initiated

                if  self.tour.slowestQuery?.duration ?? .zero < duration,
                    let uri:String = request.profile.uri
                {
                    self.tour.slowestQuery = .init(
                        duration: duration,
                        uri: uri)
                }

                //  Don’t increment stats from administrators,
                //  they will really skew the results.
                if  case nil = request.cookies.session
                {
                    let status:WritableKeyPath<ServerProfile.ByStatus, Int> = response.category
                    let agent:WritableKeyPath<ServerProfile.ByAgent, Int> = request.agent

                    self.tour.profile.requests.bytes[keyPath: agent] += response.size
                    self.tour.profile.requests.pages[keyPath: agent] += 1

                    switch agent
                    {
                    case    \.likelyBrowser:
                        //  Only count languages for browsers.
                        self.tour.profile.languages[keyPath: request.language] += 1
                        self.tour.profile.responses.toBrowsers[keyPath: status] += 1

                        self.tour.lastImpression = request.profile

                    case    \.likelyGooglebot,
                            \.likelyMajorSearchEngine,
                            \.likelyMinorSearchEngine:
                        self.tour.profile.responses.toSearch[keyPath: status] += 1

                    case    _:
                        self.tour.profile.responses.toOther[keyPath: status] += 1
                    }

                    self.tour.last = request.profile
                }

                request.promise.succeed(response)
            }
            catch let error
            {
                request.promise.fail(error)
            }
        }
    }
}
