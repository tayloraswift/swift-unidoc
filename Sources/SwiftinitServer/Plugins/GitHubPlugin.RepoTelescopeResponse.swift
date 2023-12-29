import GitHubAPI
import JSON

extension GitHubPlugin
{
    /// Models a GraphQL repo monitor response.
    struct RepoTelescopeResponse
    {
        var repos:[GitHub.Repo]

        init(repos:[GitHub.Repo])
        {
            self.repos = repos
        }
    }
}
extension GitHubPlugin.RepoTelescopeResponse:JSONObjectDecodable
{
    enum CodingKey:String, Sendable
    {
        case search
        enum Search:String, Sendable
        {
            case nodes
        }
    }

    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        let repos:[GitHub.Repo] = try json[.search].decode(
            using: CodingKey.Search.self)
        {
            try $0[.nodes].decode(as: JSON.Array.self)
            {
                try $0.map
                {
                    let node:GitHub.RepoNode = try $0.decode()
                    return node.repo
                }
            }
        }
        self.init(repos: repos)
    }
}
