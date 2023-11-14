import HTML
import Media
import URI

extension Site.Admin
{
    @frozen public
    struct Recode
    {
        @inlinable public
        init()
        {
        }
    }
}
extension Site.Admin.Recode
{
    @inlinable public static
    var name:String { "recode" }

    static
    var uri:URI { Site.Admin.uri.path / Self.name }
}
extension Site.Admin.Recode:RenderablePage
{
    public
    var title:String { "Schema - Administrator Tools" }
}
extension Site.Admin.Recode:StaticPage
{
    public
    var location:URI { Self.uri }
}
extension Site.Admin.Recode:AdministrativePage
{
    public
    func main(_ main:inout HTML.ContentEncoder, assets:StaticAssets)
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
