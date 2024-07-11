import JSON

extension GitHub.WebhookInstallationRepositories
{
    @frozen public
    enum Selection:String, JSONEncodable, JSONDecodable, Equatable, Sendable
    {
        case all
        case selected
    }
}
