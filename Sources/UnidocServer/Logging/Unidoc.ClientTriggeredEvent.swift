import HTTP

extension Unidoc {
    @frozen public struct ClientTriggeredEvent: Sendable {
        public let duration: Duration
        public let response: HTTP.ServerResponse
        public let request: Unidoc.ServerRequest

        @inlinable public init(
            duration: Duration,
            response: HTTP.ServerResponse,
            request: Unidoc.ServerRequest
        ) {
            self.duration = duration
            self.response = response
            self.request = request
        }
    }
}
