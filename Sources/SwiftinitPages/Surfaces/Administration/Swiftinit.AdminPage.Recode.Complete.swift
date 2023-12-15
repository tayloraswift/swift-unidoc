import HTML
import SwiftinitRender
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
extension Swiftinit.AdminPage.Recode.Complete:Swiftinit.RenderablePage
{
    public
    var title:String { "Migration complete" }
}
extension Swiftinit.AdminPage.Recode.Complete:Swiftinit.StaticPage
{
    public
    var location:URI { self.target.location }
}
extension Swiftinit.AdminPage.Recode.Complete:Swiftinit.AdministrativePage
{
    public
    func main(_ main:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
    {
        main[.p] = "Modified \(self.modified) of \(self.selected) vertices!"
    }
}
