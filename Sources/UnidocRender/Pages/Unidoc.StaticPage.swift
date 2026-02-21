import HTML
import HTTP
import Media
import URI

extension Unidoc {
    public protocol StaticPage: RenderablePage {
        var canonicalURI: URI? { get }
        var location: URI { get }
    }
}
extension Unidoc.StaticPage {
    @inlinable public var canonicalURI: URI? { nil }
}
extension Unidoc.StaticPage where Self: Unidoc.RenderablePage {
    public func resource(format: Unidoc.RenderFormat) -> HTTP.Resource {
        let canonical: String? = self.canonicalURI?.description
        let location: String = "\(self.location)"

        let html: HTML = self.rendered(canonical: canonical, location: location, format: format)

        return .init(
            headers: .init(canonical: canonical ?? location),
            content: .init(
                body: .binary(html.utf8),
                type: .text(.html, charset: .utf8)
            )
        )
    }
}
