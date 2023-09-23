import HTML
import URI

extension Site.Admin
{
    @frozen public
    enum Action:String, Equatable, Hashable, Sendable
    {
        case dropAccountDB = "drop-account-db"
        case dropUnidocDB = "drop-unidoc-db"

        case lintUnidocEditions = "lint-unidoc-editions"

        case rebuild = "rebuild"
        case upload = "upload"
    }
}
extension Site.Admin.Action
{
    var label:String
    {
        switch self
        {
        case .dropAccountDB:            return "Drop Account Database"
        case .dropUnidocDB:             return "Drop Unidoc Database"
        case .lintUnidocEditions:       return "Lint Editions"
        case .rebuild:                  return "Rebuild Collections"
        case .upload:                   return "Upload Snapshots"
        }
    }
}
extension Site.Admin.Action
{
    var prompt:String
    {
        switch self
        {
        case .dropAccountDB, .dropUnidocDB:
            return """
            This will drop (and reinitialize) the entire database. Are you sure?
            """

        case .lintUnidocEditions:
            return """
            This will delete all editions lacking a commit hash. Are you sure?
            """

        case .rebuild:
            return """
            This will rebuild all collections. Are you sure?
            """

        case .upload:
            return ""
        }
    }
}
extension Site.Admin.Action:RenderablePage
{
    public
    var title:String { "\(self.label)?" }
}
extension Site.Admin.Action:StaticPage
{
    public
    var location:URI { Site.Admin[self] }
}
extension Site.Admin.Action:AdministrativePage
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
            $0[.p] = self.prompt
            $0[.p]
            {
                $0[.button] { $0.type = "submit" } = self.label
            }
        }
    }
}
