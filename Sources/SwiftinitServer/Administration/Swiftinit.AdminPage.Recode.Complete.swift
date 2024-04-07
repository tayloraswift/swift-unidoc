import HTML
import SwiftinitRender
import URI

extension Swiftinit.AdminPage.Recode
{
    struct Complete
    {
        var selected:Int
        var modified:Int
        var target:Target

        init(selected:Int, modified:Int, target:Target)
        {
            self.selected = selected
            self.modified = modified
            self.target = target
        }
    }
}
extension Swiftinit.AdminPage.Recode.Complete:Unidoc.RenderablePage
{
    var title:String { "Migration complete" }
}
extension Swiftinit.AdminPage.Recode.Complete:Unidoc.StaticPage
{
    var location:URI { self.target.location }
}
extension Swiftinit.AdminPage.Recode.Complete:Unidoc.AdministrativePage
{
    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        main[.p] = "Modified \(self.modified) of \(self.selected) vertices!"
    }
}
