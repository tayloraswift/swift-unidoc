import HTML
import SwiftinitRender
import URI

extension Swiftinit.AdminPage
{
    enum Action:String, Equatable, Hashable, Sendable
    {
        case dropUnidocDB = "drop-unidoc-db"

        case restart = "restart"

        case upload = "upload"
    }
}
extension Swiftinit.AdminPage.Action
{
    var label:String
    {
        switch self
        {
        case .dropUnidocDB:             "Drop Unidoc Database"
        case .restart:                  "Restart Server"
        case .upload:                   "Upload Snapshots"
        }
    }
}
extension Swiftinit.AdminPage.Action
{
    var prompt:String
    {
        switch self
        {
        case .dropUnidocDB:
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
extension Swiftinit.AdminPage.Action:Swiftinit.RenderablePage
{
    var title:String { "\(self.label)?" }
}
extension Swiftinit.AdminPage.Action:Swiftinit.StaticPage
{
    var location:URI { Swiftinit.AdminPage[self] }
}
extension Swiftinit.AdminPage.Action:Swiftinit.AdministrativePage
{
    func main(_ main:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
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
