import HTML
import HTTP
import Media

extension Swiftinit
{
    public
    typealias DynamicPage = _SwiftinitDynamicPage
}

public
protocol _SwiftinitDynamicPage:Swiftinit.RenderablePage
{
}
extension Swiftinit.DynamicPage
{
    public
    func resource(format:Swiftinit.RenderFormat) -> HTTP.Resource
    {
        let html:HTML = self.rendered(format: format)

        return .init(content: .binary(html.utf8), type: .text(.html, charset: .utf8))
    }
}
