import HTML
import Symbols
import URI
import UnixTime

extension Unidoc
{
    struct RulesPage
    {
        private
        let package:PackageMetadata

        private
        let editors:[Unidoc.User]
        private
        let members:[Unidoc.User]
        private
        let owner:Unidoc.User?
        private
        let view:Permissions

        init(package:PackageMetadata,
            editors:[Unidoc.User],
            members:[Unidoc.User],
            owner:Unidoc.User?,
            view:Permissions)
        {
            self.package = package
            self.editors = editors
            self.members = members
            self.owner = owner
            self.view = view
        }
    }
}
extension Unidoc.RulesPage:Unidoc.RenderablePage
{
    var title:String { "Rules · \(self.package.symbol)" }
}
extension Unidoc.RulesPage:Unidoc.StaticPage
{
    var location:URI { Unidoc.RulesEndpoint[self.package.symbol] }
}
extension Unidoc.RulesPage:Unidoc.ApplicationPage
{
    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        let now:UnixInstant = .now()

        main[.section, { $0.class = "introduction" }]
        {
            $0[.h1] = "Manage collaborators"

            if  let repo:Unidoc.PackageRepo = self.package.repo
            {
                $0 += Unidoc.PackageBanner.init(repo: repo, now: now)
            }
        }

        main[.ul]
        {
            $0.class = "users"
        }
            content:
        {
            $0[.li] = owner?.card

            for user in self.members
            {
                $0[.li] = user.card
            }
            for user in self.editors
            {
                $0[.li] = user.card
            }
        }
    }
}
