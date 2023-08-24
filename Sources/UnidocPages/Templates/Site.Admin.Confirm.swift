import HTML
import URI

extension Site.Admin
{
    @frozen public
    struct Confirm
    {
        public
        var action:Site.Action
        public
        var label:String
        public
        var text:String

        @inlinable public
        init(action:Site.Action, label:String, text:String)
        {
            self.action = action
            self.label = label
            self.text = text
        }
    }
}
extension Site.Admin.Confirm:FixedPage
{
    public
    var location:URI { Site.Admin.confirm(self.action) }
    public
    var title:String { "\(self.label)?" }
}
extension Site.Admin.Confirm:AdministrativePage
{
    public
    func main(_ main:inout HTML.ContentEncoder)
    {
        main[.form]
        {
            $0.enctype = "multipart/form-data"
            $0.action = "\(self.action)"
            $0.method = "post"
        }
        content:
        {
            $0[.p] = self.text
            $0[.p]
            {
                $0[.button] { $0.type = "submit" } = self.label
            }
        }
    }
}
