import HTML
import URI

extension Site.Admin
{
    @frozen public
    struct Recode
    {
        public
        var target:Target

        @inlinable public
        init(target:Target)
        {
            self.target = target
        }
    }
}
extension Site.Admin.Recode
{
    private
    var prompt:String
    {
        switch self.target
        {
        case .packages:     return "This will recode all package records. Are you sure?"
        case .editions:     return "This will recode all edition records. Are you sure?"
        case .vertices:     return "This will recode all vertex records. Are you sure?"
        case .names:        return "This will recode all volume names. Are you sure?"
        }
    }
}
extension Site.Admin.Recode
{
    static
    subscript(target:Target) -> URI
    {
        var uri:URI = Site.Admin.uri
            uri.path.append("recode")
            uri.path.append(target.rawValue)

        return uri
    }
}
extension Site.Admin.Recode:RenderablePage
{
    public
    var title:String { "Recode \(self.target.label)?" }
}
extension Site.Admin.Recode:StaticPage
{
    public
    var location:URI { Self[self.target] }
}
extension Site.Admin.Recode:AdministrativePage
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
                $0[.button] { $0.type = "submit" } = "Recode \(self.target.label)"
            }
        }
    }
}
