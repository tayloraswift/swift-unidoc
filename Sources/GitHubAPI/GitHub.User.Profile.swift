extension GitHub.User {
    @frozen public struct Profile: Equatable, Sendable {
        /// The user’s @-name.
        public var login: String
        /// The user’s icon URL.
        public var icon: String
        /// The user’s node id. This is GitHub’s analogue of a Unidoc scalar.
        public var node: GitHub.Node

        /// The user’s location, if set.
        public var location: String?
        /// The user’s hiring status, if set.
        public var hireable: Bool?
        /// The user’s company name, if set.
        public var company: String?
        /// The user’s public email address, if set.
        public var email: String?
        /// The user’s display name, if set.
        public var name: String?
        /// The user’s blog URL, if set.
        public var blog: String?
        /// The user’s bio, if set.
        public var bio: String?
        /// The user’s X account, if set.
        public var x: String?

        public var publicRepos: Int
        public var publicGists: Int
        public var followers: Int
        public var following: Int
        public var created: String
        public var updated: String

        @inlinable public init(
            login: String,
            icon: String,
            node: GitHub.Node,
            location: String?,
            hireable: Bool?,
            company: String?,
            email: String?,
            name: String?,
            blog: String?,
            bio: String?,
            x: String?,
            publicRepos: Int,
            publicGists: Int,
            followers: Int,
            following: Int,
            created: String,
            updated: String
        ) {
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
