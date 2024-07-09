import JSON

@available(*, unavailable, message: "unimplemented")
extension GitHub.WebhookInstallationRepositories
{
    @frozen public
    enum Selection:String, JSONEncodable, JSONDecodable, Equatable, Sendable
    {
        case all
        case selected
    }
}
extension GitHub
{
    @available(*, unavailable, message: "unimplemented")
    @frozen public
    struct WebhookInstallationRepositories:Sendable
    {
        public
        let installation:Installation
        public
        let selection:Selection
        public
        let added:[Never]
        public
        let removed:[Never]
    }
}
