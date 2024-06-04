import HTML
import URI

extension Unidoc
{
    public
    protocol AdministrativePage:RenderablePage
    {
        func main(_:inout HTML.ContentEncoder, format:RenderFormat)
    }
}
extension Unidoc.AdministrativePage
{
    public
    func head(augmenting head:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        head[.link]
        {
            $0.href = "\(format.assets[.admin_css])"
            $0.rel = .stylesheet
        }
    }

    public
    func body(_ body:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        body[.header, { $0.class = "app" }]
        {
            $0[.div, { $0.class = "content" }]
            {
                $0[.nav] { $0.class = "cornice" } = Unidoc.ApplicationCornice.init()
            }
        }
        body[.div, { $0.class = "app" }]
        {
            $0[.main, { $0.class = "content" }] { self.main(&$0, format: format) }
        }
    }
}
