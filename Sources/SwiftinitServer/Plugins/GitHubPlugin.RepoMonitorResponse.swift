import GitHubAPI
import JSON

extension GitHubPlugin
{
    /// Models a GraphQL repo monitor response.
    struct RepoMonitorResponse
    {
        var repo:GitHub.Repo
        var tags:[GitHub.Tag]

        init(repo:GitHub.Repo, tags:[GitHub.Tag])
        {
            self.repo = repo
            self.tags = tags
        }
    }
}
extension GitHubPlugin.RepoMonitorResponse:JSONObjectDecodable
{
    enum CodingKey:String, Sendable
    {
        case repository
    }

    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
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
