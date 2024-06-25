import GitHubAPI
import HTML
import Media
import URI

extension Unidoc
{
    struct UserSettingsPage
    {
        private
        let user:User
        private
        let organizations:[User]

        let location:URI

        init(user:User, organizations:[User], location:URI)
        {
            self.user = user
            self.organizations = organizations
            self.location = location
        }
    }
}
extension Unidoc.UserSettingsPage:Unidoc.RenderablePage
{
    var title:String { "Account settings" }
}
extension Unidoc.UserSettingsPage:Unidoc.StaticPage
{
}
extension Unidoc.UserSettingsPage:Unidoc.ApplicationPage
{
    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
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
                $0[.dd]
                {
                    $0[.a]
                    {
                        $0.href = "\(Unidoc.UserPropertyEndpoint[self.user.id])"
                    } = "\(self.user.id)"
                }

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
                $0[.header, { $0.class = "visual" }]
                {
                    $0[.h2] = Heading.profile
                    $0[.img]
                    {
                        $0.class = "icon"
                        $0.src = self.user.icon(size: 128)
                    }
                }
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

                $0[.h2] = Heading.repositories
                $0[.p] { $0.class = "note" } = """
                You can index any GitHub repository that belongs to you or an organization you \
                have verified your membership in.
                """
                $0[.form]
                {
                    $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
                    $0.action = "\(Unidoc.Post[.packageIndex])"
                    $0.method = "post"

                    $0.class = "config"
                }
                    content:
                {
                    $0[.dl]
                    {
                        $0[.dt] = "Repo owner"
                        $0[.dd]
                        {
                            $0[.input]
                            {
                                $0.type = "text"
                                $0.name = "owner"
                                $0.value = github.login
                                $0.required = true
                            }
                        }

                        $0[.dt] = "Repo name"
                        $0[.dd]
                        {
                            $0[.input]
                            {
                                $0.type = "text"
                                $0.name = "repo"
                                $0.required = true

                                $0.pattern = #"^[a-zA-Z0-9_\-\.]+$"#
                            }
                        }
                    }

                    $0[.button]
                    {
                        $0.class = "area"
                        $0.type = "submit"
                    } = "Index GitHub repository"
                }
            }

            $0[.h2] = Heading.organizations
            switch self.organizations.count
            {
            case 0:
                $0[.p] { $0.class = "note" } = """
                You are not a verified member of any GitHub organizations!
                """

            case 1:
                $0[.p] { $0.class = "note" } = """
                You have verified your membership in one GitHub organization.
                """

            case let count:
                $0[.p] { $0.class = "note" } = """
                You have verified your membership in \(count) GitHub organizations.
                """
            }

            $0[.ul, { $0.class = "users" }]
            {
                for organization:Unidoc.User in self.organizations
                {
                    $0[.li] = organization.card()
                }
            }

            $0[.form]
            {
                $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
                $0.action = "\(Unidoc.Post[.userSyncPermissions])"
                $0.method = "post"
            }
                content:
            {
                //  We’re not passing any parameters right now, but in the future we might.
                $0[.button]
                {
                    $0.class = "area" ;
                    $0.type = "submit"
                } = "Sync GitHub permissions"
            }

            $0[.h2] = Heading.apiKeys

            let button:String

            if  let apiKey:Int64 = self.user.apiKey
            {
                button = "Scramble API key"

                $0[.dl]
                {
                    $0[.dt] = "API key"
                    $0[.dd] = String.init(UInt64.init(bitPattern: apiKey), radix: 16)

                    $0[.dt] = "Rate limit remaining"
                    $0[.dd] = "\(self.user.apiLimitLeft)"
                }
            }
            else
            {
                button = "Generate API key"

                $0[.p] = "You have not generated an API key yet."
            }

            $0[.form]
            {
                $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
                $0.action = "\(Unidoc.Post[.userConfig, really: false])"
                $0.method = "post"
            }
                content:
            {
                $0[.input]
                {
                    $0.type = "hidden"
                    $0.name = "generate-api-key"
                    $0.value = "\(self.user.id)"
                }

                $0[.button] { $0.class = "area" ; $0.type = "submit" } = button
            }
        }
    }
}
