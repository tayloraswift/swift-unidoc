import HTML
import URI

public
protocol AdministrativePage:StaticPage
{
    func main(_:inout HTML.ContentEncoder, assets:StaticAssets)
}
extension AdministrativePage
{
    public
    func head(augmenting head:inout HTML.ContentEncoder, assets:StaticAssets)
    {
        head[.link]
        {
            $0.href = "\(assets[.admin_css])"
            $0.rel = .stylesheet
        }
    }

    public
    func body(_ body:inout HTML.ContentEncoder, assets:StaticAssets)
    {
        body[.header, { $0.class = "app" }]
        {
            $0[.div, { $0.class = "content" }] { $0[.nav] = HTML.Logo.init() }
        }
        body[.div]
        {
            $0[.main, { $0.class = "content" }] { self.main(&$0, assets: assets) }
        }
    }
}
