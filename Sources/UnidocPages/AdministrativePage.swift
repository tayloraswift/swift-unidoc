import HTML
import URI

public
protocol AdministrativePage:StaticPage
{
    func main(_:inout HTML.ContentEncoder)
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
    func body(_ body:inout HTML.ContentEncoder)
    {
        body[.header, { $0.class = "app" }]
        {
            $0[.div, { $0.class = "content" }] { $0[.nav] = HTML.Logo.init() }
        }
        body[.div]
        {
            $0[.main, { $0.class = "content" }, content: self.main(_:)]
        }
    }
}
