import HTML
import Media
import Symbols
import UnixTime
import URI

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
        main[.section, { $0.class = "introduction" }]
        {
            $0[.nav, { $0.class = "breadcrumbs" }]
            {
                $0[.a]
                {
                    $0.href = "\(Unidoc.RefsEndpoint[self.package.symbol])"
                } = "\(self.package.symbol)"
            }

            $0[.h1] = "Manage collaborators"

            guard
            let repo:Unidoc.PackageRepo = self.package.repo
            else
            {
                return
            }

            $0[.p] { $0.class = "chyron" } = repo.chyron(now: format.time)
        }

        main[.ul]
        {
            $0.class = "users"
        }
            content:
        {
            $0[.li] = owner?.card(tools: .owner)

            for user in self.members
            {
                $0[.li] = user.card(tools: .member)
            }

            let package:Unidoc.Package? = self.view.owner ? package.id : nil

            for user in self.editors
            {
                $0[.li] = user.card(tools: .editor(package, user.id))
            }
        }

        main[.form]
        {
            $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
            $0.action = "\(Unidoc.Post[.packageRules])"
            $0.method = "post"

            $0.class = "config"
        }
            content:
        {
            $0[.dl]
            {
                $0[.dt] = "GitHub username"
                $0[.dd]
                {
                    $0[.input]
                    {
                        $0.type = "hidden"
                        $0.name = "package"
                        $0.value = "\(self.package.id)"
                    }

                    $0[.input]
                    {
                        $0.type = "text"
                        $0.name = "login"
                        $0.pattern = #"^[a-zA-Z0-9_\-\.]+$"#
                        $0.required = true
                    }
                }
            }

            $0[.button]
            {
                $0.class = "area"
                $0.type = "submit"

                if !self.view.authenticated
                {
                    $0.disabled = true
                    $0.title = "You are not logged in!"
                }
                else if !self.view.owner
                {
                    $0.disabled = true
                    $0.title = "You cannot grant permissions for this package!"
                }

            } = "Grant edit access"
        }
    }
}
