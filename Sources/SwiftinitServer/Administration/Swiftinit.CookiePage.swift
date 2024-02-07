import HTML
import Media
import Swiftinit
import SwiftinitRender
import URI

extension Swiftinit
{
    struct CookiePage
    {
        var cookie:String

        init(cookie:String)
        {
            self.cookie = cookie
        }
    }
}
extension Swiftinit.CookiePage
{
    static
    var name:String { "cookies" }

    static
    var uri:URI { Swiftinit.Root.admin / Self.name }
}
extension Swiftinit.CookiePage:Swiftinit.RenderablePage
{
    var title:String { "Cookies · Administrator Tools" }
}
extension Swiftinit.CookiePage:Swiftinit.StaticPage
{
    var location:URI { Self.uri }
}
extension Swiftinit.CookiePage:Swiftinit.AdministrativePage
{
    func main(_ main:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
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
                        $0[.p] { $0.class = "cookie" } = self.cookie
                        $0[.button] { $0.type = "submit" } = "Change"
                    }
                }
            }
        }
    }
}
