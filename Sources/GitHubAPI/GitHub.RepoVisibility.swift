import JSON

extension GitHub
{
    @frozen public
    enum RepoVisibility:String, JSONEncodable, JSONDecodable, Equatable, Sendable
    {
        case `public`
        case `private`
    }
}
