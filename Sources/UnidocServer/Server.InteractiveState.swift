import GitHubClient
import GitHubAPI
import HTTP
import UnidocPages

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
                let type:WritableKeyPath<ServerTour.Stats.ByType, Int> =
                    request.endpoint.statisticalType

                let response:ServerResponse = try await request.endpoint.load(
                    from: self,
                    with: request.cookies)
                    ?? .notFound(.init(
                        content: .string("not found"),
                        type: .text(.plain, charset: .utf8)))

                //  Don’t increment stats from administrators,
                //  they will really skew the results.
                if  case nil = request.cookies.session
                {
                    self.tour.stats.requests[keyPath: type] += 1
                    self.tour.stats.bytes[keyPath: type] += response.size

                    let status:WritableKeyPath<ServerTour.Stats.ByStatus, Int> =
                        response.statisticalStatus

                    self.tour.stats.responses[keyPath: status] += 1
                    self.tour.lastURI = request.uri
                    self.tour.lastUA = request.agent?.id

                    if  let category:WritableKeyPath<ServerTour.Stats.ByAgent, Int> =
                            request.agent?.statisticalCategory
                    {
                        self.tour.stats.agents[keyPath: category] += 1
                    }
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
