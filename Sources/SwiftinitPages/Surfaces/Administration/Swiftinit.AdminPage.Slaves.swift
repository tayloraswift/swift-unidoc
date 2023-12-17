import HTML
import Media
import SwiftinitRender
import URI

extension Swiftinit.AdminPage
{
    @frozen public
    struct Slaves
    {
        public
        var cookie:String

        @inlinable public
        init(cookie:String)
        {
            self.cookie = cookie
        }
    }
}
extension Swiftinit.AdminPage.Slaves
{
    @inlinable public static
    var name:String { "slaves" }

    static
    var uri:URI { Swiftinit.Admin.uri.path / Self.name }
}
extension Swiftinit.AdminPage.Slaves:Swiftinit.RenderablePage
{
    public
    var title:String { "Slaves · Administrator Tools" }
}
extension Swiftinit.AdminPage.Slaves:Swiftinit.StaticPage
{
    public
    var location:URI { Self.uri }
}
extension Swiftinit.AdminPage.Slaves:Swiftinit.AdministrativePage
{
    public
    func main(_ main:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
    {
        main[.h1] = "Manage Slaves"

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
