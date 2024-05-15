import GitHubAPI
import HTML
import HTTP
import MongoDB
import UnidocRender
import URI

extension Unidoc
{
    struct LoginPage
    {
        let client:String
        let from:String

        let flow:LoginFlow

        init(client:String, flow:LoginFlow, from:String)
        {
            self.client = client
            self.flow = flow
            self.from = from
        }
    }
}
extension Unidoc.LoginPage:Unidoc.RenderablePage, Unidoc.DynamicPage
{
    public
    var title:String { "Authenticate with GitHub" }
}
extension Unidoc.LoginPage:Unidoc.ApplicationPage
{
    public
    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        main[.section, { $0.class = "introduction" }]
        {
            $0[.h1] = switch self.flow
            {
            case .sso:  "Verify your identity"
            case .sync: "Verify your organizations"
            }
        }

        main[.section, { $0.class = "details" }]
        {
            switch self.flow
            {
            case .sso:
                $0[.p] = """
                Authenticate with GitHub to access your account. \
                We will ask you for read-only access to your teams and organizations.
                """
            case .sync:
                $0[.p] = "Authenticate with GitHub to verify your organizations."
                $0[.p, { $0.class = "note" }]
                {
                    $0 += "Some of your organizations may have policies that "
                    $0[.a]
                    {
                        $0.target = "_blank"
                        $0.href = """
                        https://docs.github.com/en/organizations/\
                        managing-oauth-access-to-your-organizations-data/\
                        about-oauth-app-access-restrictions#about-oauth-app-access-restrictions
                        """
                    } = "restrict"
                    $0 += " their visibility to third-party applications."
                }

                $0[.p] { $0.class = "note" } = """
                If your organizations are not showing up, you may need additional approvals \
                from the owners of each organization!
                """
            }
        }

        main[.form]
        {
            $0.id = "login"
            $0.method = "get"
            //  This is the same for both OAuth and GitHub Apps.
            $0.action = "https://github.com/login/oauth/authorize"
        }
            content:
        {
            $0[.input]
            {
                $0.type = "hidden"
                $0.name = "client_id"
                $0.value = self.client
            }

            $0[.input]
            {
                $0.type = "hidden"
                $0.name = "redirect_uri"
                $0.value = "\(format.server)/auth/github?from=\(self.from)&flow=\(self.flow)"
            }

            //  Note, for some reason, setting the `redirect_uri` to 127.0.0.1 does not work,
            //  even though the GitHub OAuth documentation suggests it should.
            //  https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/authorizing-oauth-apps#loopback-redirect-urls

            if  case .sync = self.flow
            {
                $0[.input] { $0.type = "hidden" ; $0.name = "scope" ; $0.value = "read:org" }
            }

            $0[.button] { $0.class = "area" ; $0.type = "submit" } = "Authenticate with GitHub"
        }
    }
}
