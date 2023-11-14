import HTML
import URI

extension Site.Admin
{
    @frozen public
    enum Action:String, Equatable, Hashable, Sendable
    {
        case dropAccountDB = "drop-account-db"
        case dropUnidocDB = "drop-unidoc-db"

        case restart = "restart"

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
        case .restart:                  return "Restart Server"
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
            """
            This will drop (and reinitialize) the entire database. Are you sure?
            """

        case .restart:
            """
            This will restart the server. Are you sure?
            """

        case .upload:
            ""
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
    func main(_ main:inout HTML.ContentEncoder, assets:StaticAssets)
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
