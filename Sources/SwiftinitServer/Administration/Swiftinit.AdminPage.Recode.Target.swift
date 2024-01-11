import HTML
import SwiftinitRender
import URI

extension Swiftinit.AdminPage.Recode
{
    enum Target:String, CaseIterable
    {
        case packages
        case editions
        case vertices
        case volumes
    }
}
extension Swiftinit.AdminPage.Recode.Target
{
    var label:String
    {
        switch self
        {
        case .packages:     "Packages"
        case .editions:     "Editions"
        case .volumes:      "Volume Metadata"
        case .vertices:     "Vertices"
        }
    }

    private
    var prompt:String
    {
        switch self
        {
        case .packages:     "This will recode all package records. Are you sure?"
        case .editions:     "This will recode all edition records. Are you sure?"
        case .volumes:      "This will recode all volume metadata. Are you sure?"
        case .vertices:     "This will recode all volume vertices. Are you sure?"
        }
    }
}
extension Swiftinit.AdminPage.Recode.Target:Swiftinit.RenderablePage
{
    var title:String { "Recode \(self.label)?" }
}
extension Swiftinit.AdminPage.Recode.Target:Swiftinit.StaticPage
{
    var location:URI { Swiftinit.AdminPage.Recode.uri.path / self.rawValue }
}
extension Swiftinit.AdminPage.Recode.Target:Swiftinit.AdministrativePage
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
                $0[.button] { $0.type = "submit" } = "Recode \(self.label)"
            }
        }
    }
}
