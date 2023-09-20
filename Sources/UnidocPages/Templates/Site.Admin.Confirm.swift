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
        let prompt:String
        switch action
        {
        case .dropAccountDB, .dropPackageDB, .dropUnidocDB:
            prompt = "This will drop (and reinitialize) the entire database. Are you sure?"

        case .lintPackageEditions:
            prompt = """
            This will delete all package editions lacking a commit hash. Are you sure?
            """

        case .recodePackageEditions:
            prompt = "This will recode all package editions. Are you sure?"

        case .recodePackageRecords:
            prompt = "This will recode all package records. Are you sure?"

        case .recodeUnidocVertices:
            prompt = "This will recode all Unidoc vertices. Are you sure?"

        case .rebuild, .upload:
            return nil
        }

        self.init(action: action,
            label: action.label,
            text: prompt)
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
