import HTML
import SwiftinitRender
import UnidocDB
import UnixTime
import URI

extension Swiftinit
{
    struct PackagesCreatedPage
    {
        private
        let groups:PackageGroups
        private
        let date:Timestamp.Date

        init(groups:PackageGroups, date:Timestamp.Date)
        {
            self.groups = groups
            self.date = date
        }
    }
}
extension Swiftinit.PackagesCreatedPage:Swiftinit.RenderablePage
{
    var title:String { "Packages · \(self.date)" }
}
extension Swiftinit.PackagesCreatedPage:Swiftinit.StaticPage
{
    var location:URI { Swiftinit.Telescope[self.date] }
}
extension Swiftinit.PackagesCreatedPage:Swiftinit.ApplicationPage
{
    func main(_ main:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
    {
        main[.section, { $0.class = "introduction" }]
        {
            $0[.h1] = self.date.short(.en)
        }

        main[.section, { $0.class = "details" }]
        {
            if  self.groups.isEmpty
            {
                $0[.p] = "No Swift repositories were created on \(self.date.long(.en))."
            }
            else
            {
                $0 += groups
            }
        }
    }
}
