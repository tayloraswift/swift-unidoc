import HTML
import UnidocRender
import URI

extension Unidoc._RecodePage
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
extension Unidoc._RecodePage.Complete:Unidoc.RenderablePage
{
    var title:String { "Migration complete" }
}
extension Unidoc._RecodePage.Complete:Unidoc.StaticPage
{
    var location:URI { self.target.location }
}
extension Unidoc._RecodePage.Complete:Unidoc.AdministrativePage
{
    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        main[.p] = "Modified \(self.modified) of \(self.selected) vertices!"
    }
}
