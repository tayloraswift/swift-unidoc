import GitHubAPI
import JSON

extension GitHub
{
    /// Models a GraphQL crawler response.
    struct TagResponse
    {
        var tag:Tag?

        init(tag:Tag?)
        {
            self.tag = tag
        }
    }
}
extension GitHub.TagResponse:JSONObjectDecodable
{
    enum CodingKey:String, Sendable
    {
        case repository
        enum Repository:String, Sendable
        {
            case ref
        }
    }

    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self = try json[.repository].decode(using: CodingKey.Repository.self)
        {
            .init(tag: try $0[.ref]?.decode(to: GitHub.Tag?.self))
        }
    }
}
