import GitHubAPI
import GitHubClient
import HTTP
import UnidocUI
import URI

extension Unidoc
{
    struct LoginOperation:Sendable
    {
        let flow:LoginFlow
        let path:URI

        init(flow:LoginFlow, from path:URI = ServerRoot.account.uri)
        {
            self.flow = flow
            self.path = path
        }
    }
}
extension Unidoc.LoginOperation:Unidoc.InteractiveOperation
{
    func load(with context:Unidoc.ServerResponseContext) -> HTTP.ServerResponse?
    {
        guard
        let oauth:GitHub.OAuth = context.server.github?.oauth
        else
        {
            return nil
        }

        /// Theoretically, we could also use a GitHub App for the permissions sync flow.
        /// However, that is much more complicated to get working, as it requires the App to
        /// be installed on both the user’s and the organization’s account, and also requires
        /// additional configuration.
        let page:Unidoc.LoginPage = .init(client: oauth.client,
            flow: self.flow,
            from: self.path)

        return .ok(page.resource(format: context.format))
    }
}
