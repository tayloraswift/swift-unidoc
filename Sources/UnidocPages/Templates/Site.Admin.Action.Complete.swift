import HTML
import URI

extension Site.Admin.Action
{
    @frozen public
    struct Complete
    {
        public
        var action:Site.Admin.Action
        public
        var text:String

        @inlinable public
        init(action:Site.Admin.Action, text:String)
        {
            self.action = action
            self.text = text
        }
    }
}
extension Site.Admin.Action.Complete:StaticPage
{
    public
    var location:URI { Site.Admin[self.action] }
    public
    var title:String { "Action complete" }
}
extension Site.Admin.Action.Complete:AdministrativePage
{
    public
    func main(_ main:inout HTML.ContentEncoder)
    {
        main[.p] = self.text
    }
}
