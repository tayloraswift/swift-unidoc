import HTML
import URI

extension Swiftinit
{
    public
    typealias AdministrativePage = _SwiftinitAdministrativePage
}

public
protocol _SwiftinitAdministrativePage:Swiftinit.StaticPage
{
    func main(_:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
}
extension Swiftinit.AdministrativePage
{
    public
    func head(augmenting head:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
    {
        head[.link]
        {
            $0.href = "\(format.assets[.admin_css])"
            $0.rel = .stylesheet
        }
    }

    public
    func body(_ body:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
    {
        body[.header, { $0.class = "app" }]
        {
            $0[.div, { $0.class = "content" }] { $0[.nav] = HTML.Logo.init() }
        }
        body[.div]
        {
            $0[.main, { $0.class = "content" }] { self.main(&$0, format: format) }
        }
    }
}
