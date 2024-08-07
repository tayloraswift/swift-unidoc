import HTML
import HTTP
import Media

extension Unidoc
{
    /// A renderable page that lacks a static URL. This protocol has no requirements; it only
    /// exists to allow users to explicitly opt-in to a default implementation for
    /// ``resource(format:)``.
    public
    protocol DynamicPage:RenderablePage
    {
    }
}
extension Unidoc.DynamicPage
{
    public
    func resource(format:Unidoc.RenderFormat) -> HTTP.Resource
    {
        let html:HTML = self.rendered(format: format)

        return .init(content: .init(
            body: .binary(html.utf8),
            type: .text(.html, charset: .utf8)))
    }
}
