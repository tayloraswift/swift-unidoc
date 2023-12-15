import GitHubAPI
import JSON

extension GitHubPlugin
{
    /// Models a GraphQL crawler response.
    struct CrawlerResponse
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
extension GitHubPlugin.CrawlerResponse:JSONObjectDecodable
{
    enum CodingKey:String, Sendable
    {
        case repository
        enum Repository:String, Sendable
        {
            case id
            case owner
            case name

            case license
            enum License:String, Sendable
            {
                case id
                case name
            }

            case topics
            enum Topics:String, Sendable
            {
                case nodes
                enum Node:String, Sendable
                {
                    case topic
                    enum Topic:String, Sendable
                    {
                        case name
                    }
                }
            }

            case master
            enum Master:String, Sendable
            {
                case name
            }

            case watchers
            enum Watchers:String, Sendable
            {
                case count
            }

            case forks
            case stars
            case size

            case archived
            case disabled
            case fork

            case homepage
            case about

            case created
            case updated
            case pushed

            case refs
            enum Refs:String, Sendable
            {
                case nodes
            }
        }
    }

    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self = try json[.repository].decode(using: CodingKey.Repository.self)
        {
            let repo:GitHub.Repo = .init(id: try $0[.id].decode(),
                owner: try $0[.owner].decode(),
                name: try $0[.name].decode(),
                license: try $0[.license].decode(
                    as: JSON.ObjectDecoder<CodingKey.Repository.License>?.self)
                {
                    guard
                    let json:JSON.ObjectDecoder<CodingKey.Repository.License> = $0
                    else
                    {
                        return nil
                    }
                    //  The GraphQL API is slightly different from the REST API. The license
                    //  field is always present, but the license id is not. For consistency,
                    //  we consider the license to be nil if the id is nil.
                    if  let id:String = try json[.id]?.decode()
                    {
                        return .init(id: id, name: try json[.name].decode())
                    }
                    else
                    {
                        return nil
                    }
                },
                topics: try $0[.topics].decode(using: CodingKey.Repository.Topics.self)
                {
                    try $0[.nodes].decode(as: JSON.Array.self)
                    {
                        try $0.map
                        {
                            try $0.decode(using: CodingKey.Repository.Topics.Node.self)
                            {
                                try $0[.topic].decode(
                                    using: CodingKey.Repository.Topics.Node.Topic.self)
                                {
                                    try $0[.name].decode()
                                }
                            }
                        }
                    }
                },
                //  This is actually nil if the repo is empty.
                //  But we would never crawl an empty repo.
                master: try $0[.master].decode(using: CodingKey.Repository.Master.self)
                {
                    try $0[.name].decode()
                },
                watchers: try $0[.watchers].decode(using: CodingKey.Repository.Watchers.self)
                {
                    try $0[.count].decode()
                },
                forks: try $0[.forks].decode(),
                stars: try $0[.stars].decode(),
                size: try $0[.size].decode(),
                archived: try $0[.archived].decode(),
                disabled: try $0[.disabled].decode(),
                fork: try $0[.fork].decode(),
                homepage: try $0[.homepage]?.decode(as: String.self) { $0.isEmpty ? nil : $0 },
                about: try $0[.about]?.decode(to: String?.self),
                created: try $0[.created].decode(),
                updated: try $0[.updated].decode(),
                pushed: try $0[.pushed].decode())

            let tags:[GitHub.Tag] = try $0[.refs].decode(using: CodingKey.Repository.Refs.self)
            {
                try $0[.nodes].decode()
            }

            return .init(repo: repo, tags: tags)
        }
    }
}
