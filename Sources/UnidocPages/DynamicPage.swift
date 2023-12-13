import HTML
import HTTP
import Media

public
protocol DynamicPage:RenderablePage
{
}
extension DynamicPage
{
    public
    func resource(format:Unidoc.RenderFormat) -> HTTP.Resource
    {
        let html:HTML = self.rendered(format: format)

        return .init(content: .binary(html.utf8), type: .text(.html, charset: .utf8))
    }
}
