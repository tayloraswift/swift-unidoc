import HTML
import UnidocRender
import URI

extension Unidoc._RecodePage
{
    enum Target:String, CaseIterable, URI.Path.ComponentConvertible
    {
        case packageDependencies = "package-dependencies"
        case packages
        case editions
        case vertices
        case volumes
    }
}
extension Unidoc._RecodePage.Target
{
    var label:String
    {
        switch self
        {
        case .packageDependencies:  "Package dependencies"
        case .packages:             "Packages"
        case .editions:             "Editions"
        case .volumes:              "Volume metadata"
        case .vertices:             "Vertices"
        }
    }

    private
    var prompt:String
    {
        switch self
        {
        case .packageDependencies:  "This will recode all package dependencies. Are you sure?"
        case .packages:             "This will recode all package records. Are you sure?"
        case .editions:             "This will recode all edition records. Are you sure?"
        case .volumes:              "This will recode all volume metadata. Are you sure?"
        case .vertices:             "This will recode all volume vertices. Are you sure?"
        }
    }
}
extension Unidoc._RecodePage.Target:Unidoc.StatusBearingPage
{
    var status:UInt { 200 }
}
extension Unidoc._RecodePage.Target:Unidoc.RenderablePage
{
    var title:String { "Recode \(self.label)?" }
}
extension Unidoc._RecodePage.Target:Unidoc.StaticPage
{
    var location:URI { Unidoc._RecodePage.uri.path / self.rawValue }
}
extension Unidoc._RecodePage.Target:Unidoc.AdministrativePage
{
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
