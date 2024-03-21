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
    public
    enum CodingKey:String, Sendable
    {
        case id
        case profile_login = "login"
        case profile_icon = "avatar_url"
        case profile_node = "node_id"
        case profile_location = "location"
        case profile_hireable = "hireable"
        case profile_company = "company"
        case profile_email = "email"
        case profile_name = "name"
        case profile_blog = "blog"
        case profile_bio = "bio"
        case profile_x = "twitter_username"
        case profile_publicRepos = "public_repos"
        case profile_publicGists = "public_gists"
        case profile_followers = "followers"
        case profile_following = "following"
        case profile_created = "created_at"
        case profile_updated = "updated_at"
    }
}
extension GitHub.User:JSONObjectDecodable, JSONDecodable
{
    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(id: try json[.id].decode(), profile: .init(
            login: try json[.profile_login].decode(),
            icon: try json[.profile_icon].decode(),
            node: try json[.profile_node].decode(),
            location: try json[.profile_location]?.decode(),
            hireable: try json[.profile_hireable]?.decode(),
            company: try json[.profile_company]?.decode(),
            email: try json[.profile_email]?.decode(),
            name: try json[.profile_name]?.decode(),
            blog: try json[.profile_blog]?.decode(),
            bio: try json[.profile_bio]?.decode(),
            x: try json[.profile_x]?.decode(),
            publicRepos: try json[.profile_publicRepos].decode(),
            publicGists: try json[.profile_publicGists].decode(),
            followers: try json[.profile_followers].decode(),
            following: try json[.profile_following].decode(),
            created: try json[.profile_created].decode(),
            updated: try json[.profile_updated].decode()))
    }
}
