import GitHubAPI
import JSON

extension GitHub
{
    /// Models a GraphQL repo monitor response.
    @frozen public
    struct RepoMonitorResponse
    {
        public
        var repo:GitHub.Repo?
        public
        var tags:[GitHub.Tag]

        init(repo:GitHub.Repo?, tags:[GitHub.Tag])
        {
            self.repo = repo
            self.tags = tags
        }
    }
}
extension GitHub.RepoMonitorResponse:JSONObjectDecodable
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case repository
    }

    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        if  case .null = json[.repository].value ?? .null
        {
            self.init(repo: nil, tags: [])
            return
        }

        self = try json[.repository].decode(using: GitHub.RepoNode.CodingKey.self)
        {
            let node:GitHub.RepoNode = try .init(json: $0)
            let tags:[GitHub.Tag] = try $0[.refs].decode(
                using: GitHub.RepoNode.CodingKey.Refs.self)
            {
                try $0[.nodes].decode()
            }

            return .init(repo: node.repo, tags: tags)
        }
    }
}
