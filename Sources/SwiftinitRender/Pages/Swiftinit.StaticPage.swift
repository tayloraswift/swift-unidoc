import HTML
import HTTP
import Media
import URI

extension Swiftinit
{
    public
    protocol StaticPage:RenderablePage
    {
        var canonicalURI:URI? { get }
        var location:URI { get }
    }
}
extension Swiftinit.StaticPage
{
    @inlinable public
    var canonicalURI:URI? { nil }
}
extension Swiftinit.StaticPage where Self:Swiftinit.RenderablePage
{
    public
    func resource(format:Swiftinit.RenderFormat) -> HTTP.Resource
    {
        let canonical:String? = self.canonicalURI?.description
        let location:String = "\(self.location)"

        let html:HTML = self.rendered(canonical: canonical, location: location, format: format)

        return .init(
            headers: .init(canonical: canonical ?? location),
            content: .binary(html.utf8),
            type: .text(.html, charset: .utf8),
            gzip: false)
    }
}
