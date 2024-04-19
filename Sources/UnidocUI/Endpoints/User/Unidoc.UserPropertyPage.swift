import HTML
import Media
import URI

extension Unidoc
{
    struct UserPropertyPage
    {
        private
        let name:String
        private
        let user:User?
        private
        let packages:PackageGroups
        private
        let id:Account

        init(name:String, user:User?, packages:PackageGroups, id:Account)
        {
            self.name = name
            self.user = user
            self.packages = packages
            self.id = id
        }
    }
}
extension Unidoc.UserPropertyPage:Unidoc.RenderablePage
{
    var title:String { "\(self.name)’s properties" }
}
extension Unidoc.UserPropertyPage:Unidoc.StaticPage
{
    var location:URI { Unidoc.UserPropertyEndpoint[self.id] }
}
extension Unidoc.UserPropertyPage:Unidoc.ApplicationPage
{
    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        main[.section, { $0.class = "introduction" }]
        {
            $0[.h1] = self.title
        }
        main[.section] { $0.class = "details" } = self.packages
    }
}
