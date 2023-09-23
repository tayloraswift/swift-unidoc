import HTML
import URI

extension Site.Admin.Recode
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
extension Site.Admin.Recode.Complete:FixedPage
{
    public
    var location:URI { Site.Admin.Recode[self.target] }
    public
    var title:String { "Migration complete" }
}
extension Site.Admin.Recode.Complete:AdministrativePage
{
    public
    func main(_ main:inout HTML.ContentEncoder)
    {
        main[.p] = "Modified \(self.modified) of \(self.selected) vertices!"
    }
}
