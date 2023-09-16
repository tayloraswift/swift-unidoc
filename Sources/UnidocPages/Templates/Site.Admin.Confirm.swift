import HTML
import URI

extension Site.Admin
{
    @frozen public
    struct Confirm
    {
        public
        var action:Action
        public
        var label:String
        public
        var text:String

        private
        init(action:Action, label:String, text:String)
        {
            self.action = action
            self.label = label
            self.text = text
        }
    }
}
extension Site.Admin.Confirm
{
    public
    init?(action:Site.Admin.Action)
    {
        switch action
        {
        case .dropAccountDB, .dropPackageDB, .dropUnidocDB:
            self.init(action: action,
                label: action.label,
                text: """
                This will drop (and reinitialize) the entire database. Are you sure?
                """)

        case .recodePackageEditions:
            self.init(action: action,
                label: action.label,
                text: """
                This will recode all package editions. Are you sure?
                """)

        case .rebuild, .upload:
            return nil
        }
    }
}
extension Site.Admin.Confirm:FixedPage
{
    public
    var location:URI { Site.Admin[self.action] }
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
            $0.action = "\(self.location)"
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
