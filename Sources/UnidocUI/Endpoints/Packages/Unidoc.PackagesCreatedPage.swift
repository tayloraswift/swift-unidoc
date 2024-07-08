import HTML
import UnidocRender
import UnidocDB
import UnixCalendar
import UnixTime
import URI

extension Unidoc
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
extension Unidoc.PackagesCreatedPage:Unidoc.RenderablePage
{
    var title:String { "Packages · \(self.date)" }
}
extension Unidoc.PackagesCreatedPage:Unidoc.StaticPage
{
    var location:URI { Unidoc.PackagesCreatedEndpoint[self.date] }
}
extension Unidoc.PackagesCreatedPage:Unidoc.ApplicationPage
{
    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        main[.section, { $0.class = "introduction" }]
        {
            $0[.nav, { $0.class = "calendar" }]
            {
                let (before, after):(Timestamp.Date, Timestamp.Date) = self.date.adjacent

                $0[.a]
                {
                    $0.href = "\(Unidoc.PackagesCreatedEndpoint[before])"
                } = "◀"

                $0[.h1] = self.date.long(format.locale)

                $0[.a]
                {
                    $0.href = "\(Unidoc.PackagesCreatedEndpoint[after])"
                } = "▶"
            }
        }

        main[.section, { $0.class = "details" }]
        {
            if  self.groups.isEmpty
            {
                $0[.p] = """
                No Swift repositories were created on \(self.date.long(.init(language: .en))).
                """
            }
            else
            {
                $0 += groups
            }
        }
    }
}
