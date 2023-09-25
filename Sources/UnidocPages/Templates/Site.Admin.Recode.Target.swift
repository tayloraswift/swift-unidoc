import HTML
import URI

extension Site.Admin.Recode
{
    @frozen public
    enum Target:String, CaseIterable
    {
        case packages
        case editions
        case vertices
        case names
    }
}
extension Site.Admin.Recode.Target
{
    var label:String
    {
        switch self
        {
        case .packages:     return "Packages"
        case .editions:     return "Editions"
        case .vertices:     return "Vertices"
        case .names:        return "Volume Names"
        }
    }

    private
    var prompt:String
    {
        switch self
        {
        case .packages:     return "This will recode all package records. Are you sure?"
        case .editions:     return "This will recode all edition records. Are you sure?"
        case .vertices:     return "This will recode all vertex records. Are you sure?"
        case .names:        return "This will recode all volume names. Are you sure?"
        }
    }
}
extension Site.Admin.Recode.Target:RenderablePage
{
    public
    var title:String { "Recode \(self.label)?" }
}
extension Site.Admin.Recode.Target:StaticPage
{
    public
    var location:URI { Site.Admin.Recode.uri.path / self.rawValue }
}
extension Site.Admin.Recode.Target:AdministrativePage
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
                $0[.button] { $0.type = "submit" } = "Recode \(self.label)"
            }
        }
    }
}
