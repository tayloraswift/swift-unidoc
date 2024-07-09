import GitHubAPI
import JSON

extension GitHub
{
    /// A wrapper around a ``Repo`` that uses the GraphQL-flavored format.
    @frozen public
    struct RepoNode
    {
        public
        let repo:Repo

        init(repo:Repo)
        {
            self.repo = repo
        }
    }
}
extension GitHub.RepoNode:JSONObjectDecodable
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case id
        case owner
        case name
        case node

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

        //  Not present in this type, but could be added as a table join.
        case refs
        enum Refs:String, Sendable
        {
            case nodes
        }
    }

    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(repo: .init(id: try json[.id].decode(),
            owner: try json[.owner].decode(),
            name: try json[.name].decode(),
            node: try json[.node].decode(),
            license: try json[.license].decode(as: JSON.ObjectDecoder<CodingKey.License>?.self)
            {
                guard
                let json:JSON.ObjectDecoder<CodingKey.License> = $0
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
            topics: try json[.topics].decode(using: CodingKey.Topics.self)
            {
                try $0[.nodes].decode(as: JSON.Array.self)
                {
                    try $0.map
                    {
                        try $0.decode(using: CodingKey.Topics.Node.self)
                        {
                            try $0[.topic].decode(using: CodingKey.Topics.Node.Topic.self)
                            {
                                try $0[.name].decode()
                            }
                        }
                    }
                }
            },
            //  This is actually nil if the repo is empty.
            //  But we would never crawl an empty repo.
            master: try json[.master].decode(using: CodingKey.Master.self)
            {
                try $0[.name].decode()
            },
            watchers: try json[.watchers].decode(using: CodingKey.Watchers.self)
            {
                try $0[.count].decode()
            },
            forks: try json[.forks].decode(),
            stars: try json[.stars].decode(),
            size: try json[.size].decode(),
            archived: try json[.archived].decode(),
            disabled: try json[.disabled].decode(),
            fork: try json[.fork].decode(),
            //  Yes, `String?`, the GitHub API does occasionally return explicit null.
            homepage: try json[.homepage]?.decode(as: String?.self)
            {
                $0.map { $0.isEmpty ? nil : $0 } ?? nil
            },
            about: try json[.about]?.decode(to: String?.self),
            created: try json[.created].decode(),
            updated: try json[.updated].decode(),
            pushed: try json[.pushed].decode()))
    }
}
