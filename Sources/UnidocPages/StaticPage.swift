import HTML
import HTTP
import Media
import URI

public
protocol StaticPage:RenderablePage
{
    var canonicalURI:URI? { get }
    var location:URI { get }
}
extension StaticPage
{
    @inlinable public
    var canonicalURI:URI? { nil }
}
extension StaticPage where Self:StaticRoot
{
    @inlinable public
    var location:URI { Self.uri }
}
extension StaticPage where Self:RenderablePage
{
    public
    func resource(format:Unidoc.RenderFormat) -> HTTP.Resource
    {
        let canonical:String? = self.canonicalURI?.description
        let location:String = "\(self.location)"

        let html:HTML = self.rendered(canonical: canonical, location: location, format: format)

        return .init(
            headers: .init(canonical: canonical ?? location),
            content: .binary(html.utf8),
            type: .text(.html, charset: .utf8))
    }
}
