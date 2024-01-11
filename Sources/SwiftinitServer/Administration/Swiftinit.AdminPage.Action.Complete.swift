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
extension Swiftinit.AdminPage.Action.Complete:Swiftinit.StaticPage
{
    var location:URI { Swiftinit.AdminPage[self.action] }
    var title:String { "Action complete" }
}
extension Swiftinit.AdminPage.Action.Complete:Swiftinit.AdministrativePage
{
    func main(_ main:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
    {
        main[.p] = self.text
    }
}
