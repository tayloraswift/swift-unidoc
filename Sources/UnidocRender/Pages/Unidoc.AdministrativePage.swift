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
        body[.div, { $0.class = "app navigator" }]
        {
            $0[.header]
            {
                $0[.nav] = format.cornice
            }
        }
        body[.div, { $0.class = "app" }]
        {
            $0[.main] { self.main(&$0, format: format) }
        }
    }
}
