import GitHubIntegration
import MongoDB
import HTML
import HTTPServer
import URI

extension Site
{
    @frozen public
    struct Login
    {
        public
        let app:GitHubApplication

        @inlinable public
        init(app:GitHubApplication)
        {
            self.app = app
        }
    }
}
extension Site.Login:FixedRoot
{
    @inlinable public static
    var root:String { "login" }
}
extension Site.Login:FixedPage
{
    public
    var title:String { "Log in with GitHub" }

    public
    func head(augmenting head:inout HTML.ContentEncoder)
    {
        head[unsafe: .script] = """
        const client = ["\(self.app.id)"];
        """
    }
}
extension Site.Login:AdministrativePage
{
    public
    func main(_ main:inout HTML.ContentEncoder)
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
            $0[.input] { $0.type = "hidden" ; $0.name = "client_id" ; $0.value = self.app.id }
            $0[.input] { $0.type = "hidden" ; $0.name = "scope" ; $0.value = "repo" }

            $0[.input] { $0.type = "submit" ; $0.value = "Log in with GitHub" }
        }
    }
}
