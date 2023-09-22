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
        case .dropAccountDB, .dropUnidocDB:
            prompt = "This will drop (and reinitialize) the entire database. Are you sure?"

        case .lintUnidocEditions:
            prompt = """
            This will delete all editions lacking a commit hash. Are you sure?
            """

        case .recodeUnidocRepos:
            prompt = "This will recode all repo records. Are you sure?"

        case .recodeUnidocEditions:
            prompt = "This will recode all edition records. Are you sure?"

        case .recodeUnidocVertices:
            prompt = "This will recode all vertices. Are you sure?"

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
