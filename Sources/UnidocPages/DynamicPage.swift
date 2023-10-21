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
    func resource(assets:StaticAssets) -> ServerResource
    {
        let html:HTML = self.rendered(assets: assets)

        return .init(content: .binary(html.utf8), type: .text(.html, charset: .utf8))
    }
}
