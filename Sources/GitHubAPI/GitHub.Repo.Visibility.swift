import JSON

extension GitHub.Repo
{
    @frozen public
    enum Visibility:String, JSONEncodable, JSONDecodable, Equatable, Sendable
    {
        case `public`
        case `private`
    }
}
