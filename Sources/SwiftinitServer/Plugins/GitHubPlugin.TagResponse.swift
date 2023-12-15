import GitHubAPI
import JSON

extension GitHubPlugin
{
    /// Models a GraphQL crawler response.
    struct TagResponse
    {
        var tag:GitHub.Tag?

        init(tag:GitHub.Tag?)
        {
            self.tag = tag
        }
    }
}
extension GitHubPlugin.TagResponse:JSONObjectDecodable
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
