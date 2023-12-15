import HTML
import URI

extension Swiftinit.AdminPage.Recode
{
    @frozen public
    struct Complete
    {
        public
        var selected:Int
        public
        var modified:Int
        public
        var target:Target

        @inlinable public
        init(selected:Int, modified:Int, target:Target)
        {
            self.selected = selected
            self.modified = modified
            self.target = target
        }
    }
}
extension Swiftinit.AdminPage.Recode.Complete:RenderablePage
{
    public
    var title:String { "Migration complete" }
}
extension Swiftinit.AdminPage.Recode.Complete:StaticPage
{
    public
    var location:URI { self.target.location }
}
extension Swiftinit.AdminPage.Recode.Complete:AdministrativePage
{
    public
    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        main[.p] = "Modified \(self.modified) of \(self.selected) vertices!"
    }
}
