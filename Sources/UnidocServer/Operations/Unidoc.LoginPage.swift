import GitHubAPI
import HTML
import HTTP
import MongoDB
import UnidocRender
import URI

extension Unidoc
{
    @frozen public
    struct LoginPage
    {
        @usableFromInline
        let oauth:GitHub.OAuth
        @usableFromInline
        let path:String

        @inlinable public
        init(oauth:GitHub.OAuth, from path:String)
        {
            self.oauth = oauth
            self.path = path
        }
    }
}
extension Unidoc.LoginPage:Unidoc.StaticPage
{
    @inlinable public
    var location:URI { Unidoc.ServerRoot.login.uri }
}
extension Unidoc.LoginPage:Unidoc.RenderablePage
{
    public
    var title:String { "Log in with GitHub" }
}
extension Unidoc.LoginPage:Unidoc.ApplicationPage
{
    public
    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        main[.section, { $0.class = "introduction" }]
        {
            $0[.h1] = "Verify your identity"
        }

        main[.section, { $0.class = "details" }]
        {
            $0[.p] = "Authenticate with GitHub to manage package documentation."
        }

        main[.form]
        {
            $0.id = "login"
            $0.method = "get"
            $0.action = "https://github.com/login/oauth/authorize"
        }
            content:
        {
            $0[.input]
            {
                $0.type = "hidden"
                $0.name = "client_id"
                $0.value = self.oauth.client
            }

            $0[.input]
            {
                $0.type = "hidden"
                $0.name = "redirect_uri"
                $0.value = "\(format.server)/auth/github?from=\(self.path)"
            }

            //  Note, for some reason, setting the `redirect_uri` to 127.0.0.1 does not work,
            //  even though the GitHub OAuth documentation suggests it should.
            //  https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/authorizing-oauth-apps#loopback-redirect-urls

            //  Don’t actually need this yet.
            // $0[.input] { $0.type = "hidden" ; $0.name = "scope" ; $0.value = "user:email" }

            $0[.button] { $0.class = "area" ; $0.type = "submit" } = "Authenticate with GitHub"
        }
    }
}
