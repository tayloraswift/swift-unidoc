import GitHubAPI

extension Unidoc.WebhookOperation
{
    enum Event
    {
        case installation(GitHub.WebhookInstallation)
        case create(GitHub.WebhookCreate)
        case ignore(String)
    }
}
