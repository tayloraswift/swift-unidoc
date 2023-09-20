import JSON

extension GitHub
{
    @frozen public
    struct User:Identifiable, Equatable, Sendable
    {
        public
        let id:Int32

        /// The user’s @-name.
        public
        var login:String
        /// The user’s icon URL.
        public
        var icon:String
        /// The user’s node id. This is GitHub’s analogue of a Unidoc scalar.
        public
        var node:String

        /// The user’s location, if set.
        public
        var location:String?
        /// The user’s hiring status, if set.
        public
        var hireable:Bool?
        /// The user’s company name, if set.
        public
        var company:String?
        /// The user’s public email address, if set.
        public
        var email:String?
        /// The user’s display name, if set.
        public
        var name:String?
        /// The user’s blog URL, if set.
        public
        var blog:String?
        /// The user’s bio, if set.
        public
        var bio:String?
        /// The user’s X account, if set.
        public
        var x:String?

        public
        var publicRepos:Int
        public
        var publicGists:Int
        public
        var followers:Int
        public
        var following:Int
        public
        var created:String
        public
        var updated:String

        @inlinable public
        init(id:Int32,
            login:String,
            icon:String,
            node:String,
            location:String? = nil,
            hireable:Bool? = nil,
            company:String? = nil,
            email:String? = nil,
            name:String? = nil,
            blog:String? = nil,
            bio:String? = nil,
            x:String? = nil,
            publicRepos:Int = 0,
            publicGists:Int = 0,
            followers:Int = 0,
            following:Int = 0,
            created:String,
            updated:String)
        {
            self.id = id
            self.login = login
            self.icon = icon
            self.node = node
            self.location = location
            self.hireable = hireable
            self.company = company
            self.email = email
            self.name = name
            self.blog = blog
            self.bio = bio
            self.x = x
            self.publicRepos = publicRepos
            self.publicGists = publicGists
            self.followers = followers
            self.following = following
            self.created = created
            self.updated = updated
        }
    }
}
extension GitHub.User:JSONObjectDecodable
{
    public
    enum CodingKey:String
    {
        case id
        case login
        case icon = "avatar_url"
        case node = "node_id"
        case location
        case hireable
        case company
        case email
        case name
        case blog
        case bio
        case x = "twitter_username"
        case publicRepos = "public_repos"
        case publicGists = "public_gists"
        case followers
        case following
        case created = "created_at"
        case updated = "updated_at"
    }

    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(id: try json[.id].decode(),
            login: try json[.login].decode(),
            icon: try json[.icon].decode(),
            node: try json[.node].decode(),
            location: try json[.location]?.decode(),
            hireable: try json[.hireable]?.decode(),
            company: try json[.company]?.decode(),
            email: try json[.email]?.decode(),
            name: try json[.name]?.decode(),
            blog: try json[.blog]?.decode(),
            bio: try json[.bio]?.decode(),
            x: try json[.x]?.decode(),
            publicRepos: try json[.publicRepos].decode(),
            publicGists: try json[.publicGists].decode(),
            followers: try json[.followers].decode(),
            following: try json[.following].decode(),
            created: try json[.created].decode(),
            updated: try json[.updated].decode())
    }
}
