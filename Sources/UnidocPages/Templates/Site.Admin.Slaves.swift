import HTML
import Media
import URI

extension Site.Admin
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
extension Site.Admin.Slaves
{
    @inlinable public static
    var name:String { "slaves" }

    static
    var uri:URI { Site.Admin.uri.path / Self.name }
}
extension Site.Admin.Slaves:RenderablePage
{
    public
    var title:String { "Slaves - Administrator Tools" }
}
extension Site.Admin.Slaves:StaticPage
{
    public
    var location:URI { Self.uri }
}
extension Site.Admin.Slaves:AdministrativePage
{
    public
    func main(_ main:inout HTML.ContentEncoder)
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
