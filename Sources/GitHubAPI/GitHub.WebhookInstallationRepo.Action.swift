import JSON

extension GitHub.WebhookInstallationRepositories
{
    @frozen @usableFromInline
    enum Action:String, JSONDecodable
    {
        case added
        case removed
    }
}
