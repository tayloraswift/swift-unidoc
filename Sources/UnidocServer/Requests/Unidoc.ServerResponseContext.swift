import UnidocRender
import URI

extension Unidoc {
    @frozen public struct ServerResponseContext: Sendable {
        public let request: ServerRequest
        public let format: RenderFormat
        public let server: Server

        init(request: ServerRequest, format: RenderFormat, server: Server) {
            self.request = request
            self.format = format
            self.server = server
        }
    }
}
