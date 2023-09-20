import GitHubClient
import GitHubIntegration
import HTTP
import UnidocPages

extension Server
{
    @dynamicMemberLookup
    struct State
    {
        private
        let server:Server
        let github:GitHubPartner?

        var tour:ServerTour

        init(server:Server, github:GitHubPartner?)
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
                    ?? .resource(.init(.none,
                        content: .string("not found"),
                        type: .text(.plain, charset: .utf8)))

                self.tour.stats.requests[keyPath: type] += 1

                let status:WritableKeyPath<ServerTour.Stats.ByStatus, Int>
                switch response
                {
                case .resource(let resource):
                    self.tour.stats.bytes[keyPath: type] += resource.content.size
                    status = resource.statisticalStatus

                case .redirect(.temporary, _):
                    status = \.redirectedTemporarily

                case .redirect(.permanent, _):
                    status = \.redirectedPermanently
                }

                //  Don’t count visits to the admin tools.
                if  type != \.restricted
                {
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
