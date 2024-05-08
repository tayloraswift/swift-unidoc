import GitHubAPI
import JSON

extension GitHub
{
    /// Models a GraphQL crawler response.
    @frozen public
    struct RefResponse
    {
        public
        var ref:Ref?

        init(ref:Ref?)
        {
            self.ref = ref
        }
    }
}
extension GitHub.RefResponse:JSONObjectDecodable
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case repository
        enum Repository:String, Sendable
        {
            case ref
        }
    }

    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self = try json[.repository].decode(using: CodingKey.Repository.self)
        {
            .init(ref: try $0[.ref]?.decode(to: GitHub.Ref?.self))
        }
    }
}
