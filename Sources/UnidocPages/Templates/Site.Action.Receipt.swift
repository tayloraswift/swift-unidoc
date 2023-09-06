import HTML
import URI

extension Site.Admin
{
    @frozen public
    struct Receipt
    {
        public
        var action:Action
        public
        var text:String

        @inlinable public
        init(action:Action, text:String)
        {
            self.action = action
            self.text = text
        }
    }
}
extension Site.Admin.Receipt:FixedPage
{
    public
    var location:URI { Site.Admin[self.action] }
    public
    var title:String { "Action complete" }
}
extension Site.Admin.Receipt:AdministrativePage
{
    public
    func main(_ main:inout HTML.ContentEncoder)
    {
        main[.p] = self.text
    }
}
