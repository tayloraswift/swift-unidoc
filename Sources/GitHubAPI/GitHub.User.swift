import JSON

extension GitHub
{
    @frozen public
    struct User:Identifiable, Equatable, Sendable
    {
        public
        let id:UInt32
        public
        var profile:Profile

        @inlinable public
        init(id:UInt32, profile:Profile)
        {
            self.id = id
            self.profile = profile
        }
    }
}
extension GitHub.User
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case id
        case login
        case avatar_url
        case node_id
        case location
        case hireable
        case company
        case email
        case name
        case blog
        case bio
        case twitter_username
        case public_repos
        case public_gists
        case followers
        case following
        case created_at
        case updated_at
    }
}
extension GitHub.User:JSONObjectDecodable, JSONDecodable
{
    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(id: try json[.id].decode(), profile: .init(
            login: try json[.login].decode(),
            icon: try json[.avatar_url].decode(),
            node: try json[.node_id].decode(),
            location: try json[.location]?.decode(),
            hireable: try json[.hireable]?.decode(),
            company: try json[.company]?.decode(),
            email: try json[.email]?.decode(),
            name: try json[.name]?.decode(),
            blog: try json[.blog]?.decode(),
            bio: try json[.bio]?.decode(),
            x: try json[.twitter_username]?.decode(),
            publicRepos: try json[.public_repos].decode(),
            publicGists: try json[.public_gists].decode(),
            followers: try json[.followers].decode(),
            following: try json[.following].decode(),
            created: try json[.created_at].decode(),
            updated: try json[.updated_at].decode()))
    }
}
