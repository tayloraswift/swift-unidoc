import GitHubClient
import GitHubAPI
import HTTP
import UnidocPages

extension Server
{
    @dynamicMemberLookup
    struct State
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
extension Server.State
{
    subscript<T>(dynamicMember keyPath:KeyPath<Server, T>) -> T
    {
        self.server[keyPath: keyPath]
    }
}
extension Server.State
{
    mutating
    func respond(to requests:AsyncStream<Server.Request>) async throws
    {
        for await request:Server.Request in requests
        {
            try Task.checkCancellation()

            do
            {
                let type:WritableKeyPath<ServerTour.Stats.ByType, Int> =
                    request.operation.statisticalType

                let response:ServerResponse = try await request.operation.load(
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
