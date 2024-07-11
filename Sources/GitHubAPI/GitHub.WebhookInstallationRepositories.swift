import JSON

extension GitHub
{
    @frozen public
    struct WebhookInstallationRepositories:Equatable, Sendable
    {
        public
        let installation:Installation
        public
        let selection:Selection
        public
        let delta:Delta

        @inlinable public
        init(installation:Installation, selection:Selection, delta:Delta)
        {
            self.installation = installation
            self.selection = selection
            self.delta = delta
        }
    }
}
extension GitHub.WebhookInstallationRepositories:JSONObjectDecodable
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case action
        case installation
        case repository_selection
        case repositories_added
        case repositories_removed
    }

    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        let delta:Delta

        switch try json[.action].decode(to: Action.self)
        {
        case .added:    delta = .additions(try json[.repositories_added].decode())
        case .removed:  delta = .deletions(try json[.repositories_removed].decode())
        }

        self.init(installation: try json[.installation].decode(),
            selection: try json[.repository_selection].decode(),
            delta: delta)
    }
}
