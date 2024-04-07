import HTML
import SwiftinitRender
import URI

extension Swiftinit.AdminPage.Action
{
    struct Complete
    {
        var action:Swiftinit.AdminPage.Action
        var text:String

        init(action:Swiftinit.AdminPage.Action, text:String)
        {
            self.action = action
            self.text = text
        }
    }
}
extension Swiftinit.AdminPage.Action.Complete:Unidoc.StaticPage
{
    var location:URI { Swiftinit.AdminPage[self.action] }
    var title:String { "Action complete" }
}
extension Swiftinit.AdminPage.Action.Complete:Unidoc.AdministrativePage
{
    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        main[.p] = self.text
    }
}
