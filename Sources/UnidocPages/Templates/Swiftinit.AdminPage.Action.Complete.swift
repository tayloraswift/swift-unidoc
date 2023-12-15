import HTML
import URI

extension Swiftinit.AdminPage.Action
{
    @frozen public
    struct Complete
    {
        public
        var action:Swiftinit.AdminPage.Action
        public
        var text:String

        @inlinable public
        init(action:Swiftinit.AdminPage.Action, text:String)
        {
            self.action = action
            self.text = text
        }
    }
}
extension Swiftinit.AdminPage.Action.Complete:StaticPage
{
    public
    var location:URI { Swiftinit.AdminPage[self.action] }
    public
    var title:String { "Action complete" }
}
extension Swiftinit.AdminPage.Action.Complete:AdministrativePage
{
    public
    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        main[.p] = self.text
    }
}
