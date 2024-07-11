import JSON

extension GitHub
{
    @frozen public
    struct WebhookInstallation:Equatable, Sendable
    {
        public
        let action:Action
        public
        let installation:Installation

        @inlinable public
        init(action:Action, installation:Installation)
        {
            self.action = action
            self.installation = installation
        }
    }
}
extension GitHub.WebhookInstallation:JSONObjectDecodable
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case action
        case installation
    }

    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(action: try json[.action].decode(),
            installation: try json[.installation].decode())
    }
}
