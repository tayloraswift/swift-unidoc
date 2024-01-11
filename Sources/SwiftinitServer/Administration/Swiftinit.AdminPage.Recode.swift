import HTML
import Media
import Swiftinit
import SwiftinitRender
import URI

extension Swiftinit.AdminPage
{
    struct Recode
    {
        init()
        {
        }
    }
}
extension Swiftinit.AdminPage.Recode
{
    static
    var name:String { "recode" }

    static
    var uri:URI { Swiftinit.Root.admin / Self.name }
}
extension Swiftinit.AdminPage.Recode:Swiftinit.RenderablePage
{
    var title:String { "Schema · Administrator Tools" }
}
extension Swiftinit.AdminPage.Recode:Swiftinit.StaticPage
{
    var location:URI { Self.uri }
}
extension Swiftinit.AdminPage.Recode:Swiftinit.AdministrativePage
{
    func main(_ main:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
    {
        main[.h1] = "Manage Schema"
        main[.ul]
        {
            for target:Target in Target.allCases
            {
                $0[.li]
                {
                    $0[.form]
                    {
                        $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
                        $0.action = "\(target.location)"
                        $0.method = "get"
                    }
                        content:
                    {
                        $0[.p]
                        {
                            $0[.button] { $0.type = "submit" } = "Recode \(target.label)"
                        }
                    }
                }
            }
        }
    }
}
