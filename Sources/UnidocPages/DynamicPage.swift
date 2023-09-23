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
    func resource() -> ServerResource
    {
        let html:HTML = self.rendered()

        return .init(content: .binary(html.utf8), type: .text(.html, charset: .utf8))
    }
}
