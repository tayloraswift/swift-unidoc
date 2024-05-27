import HTML
import Media
import UnidocRender
import URI

extension Unidoc
{
    struct CookiePage
    {
        var secrets:UserSecrets

        init(secrets:UserSecrets)
        {
            self.secrets = secrets
        }
    }
}
extension Unidoc.CookiePage
{
    static
    var name:String { "cookies" }

    static
    var uri:URI { Unidoc.ServerRoot.admin / Self.name }
}
extension Unidoc.CookiePage:Unidoc.RenderablePage
{
    var title:String { "Cookies · Administrator Tools" }
}
extension Unidoc.CookiePage:Unidoc.StaticPage
{
    var location:URI { Self.uri }
}
extension Unidoc.CookiePage:Unidoc.AdministrativePage
{
    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        main[.h1] = "Manage cookies"

        main[.section, { $0.class = "cookie-jar" }]
        {
            $0[.h2] = "Cookie Jar"

            $0[.form]
            {
                $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
                $0.action = "\(self.location)"
                $0.method = "post"
            }
                content:
            {
                $0[.dl]
                {
                    $0[.dt] = "Cookie"
                    $0[.dd]
                    {
                        $0[.p] { $0.class = "cookie" } = "\(self.secrets.web)"
                        $0[.button] { $0.type = "submit" } = "Change"
                    }
                }
            }
        }
    }
}
