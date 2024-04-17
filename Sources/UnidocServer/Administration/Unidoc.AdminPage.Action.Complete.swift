import HTML
import UnidocRender
import URI

extension Unidoc.AdminPage.Action
{
    struct Complete
    {
        var action:Unidoc.AdminPage.Action
        var text:String

        init(action:Unidoc.AdminPage.Action, text:String)
        {
            self.action = action
            self.text = text
        }
    }
}
extension Unidoc.AdminPage.Action.Complete:Unidoc.StaticPage
{
    var location:URI { Unidoc.AdminPage[self.action] }
    var title:String { "Action complete" }
}
extension Unidoc.AdminPage.Action.Complete:Unidoc.AdministrativePage
{
    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        main[.p] = self.text
    }
}
