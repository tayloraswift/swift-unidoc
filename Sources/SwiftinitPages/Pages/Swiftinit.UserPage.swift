import GitHubAPI
import HTML
import URI

extension Swiftinit
{
    struct UserPage
    {
        private
        let user:Unidoc.User

        init(user:Unidoc.User)
        {
            self.user = user
        }
    }
}
extension Swiftinit.UserPage
{
}
extension Swiftinit.UserPage:Swiftinit.RenderablePage
{
    var title:String { "Account settings" }
}
extension Swiftinit.UserPage:Swiftinit.StaticPage
{
    var location:URI { Swiftinit.Root.acct.uri }
}
extension Swiftinit.UserPage:Swiftinit.ApplicationPage
{
    func main(_ main:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
    {
        main[.section, { $0.class = "introduction" }]
        {
            $0[.h1] = "Account settings"
        }

        main[.section, { $0.class = "details" }]
        {
            $0[.dl]
            {
                $0[.dt] = "User ID"
                $0[.dd] = "\(self.user.id)"

                $0[.dt] = "User type"
                $0[.dd] = switch (self.user.id.type, self.user.level)
                {
                case (_, .administratrix):  "Administratrix"
                case (.unidoc, _):          "Unidoc"
                case (.github, _):          "GitHub"
                }
            }

            if  let github:GitHub.User.Profile = self.user.github
            {
                $0[.h2] = "GitHub profile"

                $0[.dl]
                {
                    $0[.dt] = "GitHub name"
                    $0[.dd]
                    {
                        $0[.a]
                        {
                            $0.href = "https://github.com/\(github.login)"
                            $0.target = "_blank"
                        } = "@\(github.login)"
                    }

                    $0[.dt] = "Display name"
                    $0[.dd] = github.name

                    $0[.dt] = "Email"
                    $0[.dd] = github.email
                }
            }
        }
    }
}
