import GitHubAPI
import MongoDB
import HTML
import HTTP
import URI

extension Swiftinit
{
    @frozen public
    struct LoginPage
    {
        public
        let app:GitHubOAuth

        @inlinable public
        init(app:GitHubOAuth)
        {
            self.app = app
        }
    }
}
extension Swiftinit.LoginPage:StaticPage
{
    @inlinable public
    var location:URI { Swiftinit.Login.uri }
}
extension Swiftinit.LoginPage:RenderablePage
{
    public
    var title:String { "Log in with GitHub" }
}
extension Swiftinit.LoginPage:AdministrativePage
{
    public
    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        main[.p] = """
        Log in with GitHub to manage package documentation. You must have write access to the
        package repository to change package settings.
        """

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
                $0.value = self.app.client
            }
            //  Don’t actually need this yet.
            // $0[.input] { $0.type = "hidden" ; $0.name = "scope" ; $0.value = "user:email" }

            $0[.input] { $0.type = "submit" ; $0.value = "Log in with GitHub" }
        }
    }
}
