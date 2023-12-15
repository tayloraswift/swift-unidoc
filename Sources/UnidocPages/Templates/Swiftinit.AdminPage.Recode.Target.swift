import HTML
import URI

extension Swiftinit.AdminPage.Recode
{
    @frozen public
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
        case .packages:     return "Packages"
        case .editions:     return "Editions"
        case .volumes:      return "Volume Metadata"
        case .vertices:     return "Vertices"
        }
    }

    private
    var prompt:String
    {
        switch self
        {
        case .packages:     return "This will recode all package records. Are you sure?"
        case .editions:     return "This will recode all edition records. Are you sure?"
        case .volumes:      return "This will recode all volume metadata. Are you sure?"
        case .vertices:     return "This will recode all volume vertices. Are you sure?"
        }
    }
}
extension Swiftinit.AdminPage.Recode.Target:RenderablePage
{
    public
    var title:String { "Recode \(self.label)?" }
}
extension Swiftinit.AdminPage.Recode.Target:StaticPage
{
    public
    var location:URI { Swiftinit.AdminPage.Recode.uri.path / self.rawValue }
}
extension Swiftinit.AdminPage.Recode.Target:AdministrativePage
{
    public
    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
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
