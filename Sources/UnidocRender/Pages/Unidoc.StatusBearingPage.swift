import HTTP

extension Unidoc {
    public protocol StatusBearingPage: RenderablePage {
        var status: UInt { get }
    }
}
extension Unidoc.StatusBearingPage {
    @inlinable public func response(format: Unidoc.RenderFormat) -> HTTP.ServerResponse {
        .resource(self.resource(format: format), status: self.status)
    }
}
