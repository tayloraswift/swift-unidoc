import JSON

extension GitHub
{
    @frozen public
    struct Repo:Identifiable, Equatable, Sendable
    {
        public
        let id:Int32
        public
        var owner:Owner
        public
        var name:String

        /// The repo’s license, if GitHub was able to detect it.
        public
        var license:License?
        /// The repo’s topic tags.
        public
        var topics:[String]
        /// The name of the repo’s default branch.
        public
        var master:String?

        /// The number of subscribers this repo has. Depending on the endpoint, this field
        /// might be missing. For example, it is missing from the webhook repo events.
        public
        var watchers:Int?
        /// The number of forks this repo has.
        public
        var forks:Int
        /// The number of stargazers this repo has.
        public
        var stars:Int
        /// The approximate size of the repo, in kilobytes.
        public
        var size:Int

        /// Indicates if the repo is archived.
        public
        var archived:Bool
        /// Indicates if the repo is disabled.
        public
        var disabled:Bool
        /// Indicates if the repo is a fork.
        public
        var fork:Bool

        /// The repo’s homepage URL, if set.
        public
        var homepage:String?
        /// The repo’s description, if set.
        public
        var about:String?

        /// When the repository was first created.
        public
        var created:String
        /// When the repository itself (as opposed to its content) was last updated.
        /// This is usually different from ``pushed``.
        public
        var updated:String
        /// When the repository content (as opposed to its metadata) was last pushed to.
        /// This is usually different from ``updated``.
        public
        var pushed:String

        @inlinable public
        init(id:Int32,
            owner:Owner,
            name:String,
            license:License? = nil,
            topics:[String] = [],
            master:String?,
            watchers:Int?,
            forks:Int,
            stars:Int,
            size:Int,
            archived:Bool,
            disabled:Bool,
            fork:Bool,
            homepage:String? = nil,
            about:String? = nil,
            created:String,
            updated:String,
            pushed:String)
        {
            self.id = id
            self.owner = owner
            self.name = name
            self.license = license
            self.topics = topics
            self.master = master
            self.watchers = watchers
            self.forks = forks
            self.stars = stars
            self.size = size
            self.archived = archived
            self.disabled = disabled
            self.fork = fork
            self.homepage = homepage
            self.about = about
            self.created = created
            self.updated = updated
            self.pushed = pushed
        }
    }
}
extension GitHub.Repo:JSONObjectDecodable
{
    public
    enum CodingKey:String, Sendable
    {
        case id
        case owner
        case name

        @available(*, unavailable)
        case node = "node_id"

        case license
        case topics
        case master = "default_branch"
        // not `watchers_count`, which is just stargazers
        case watchers = "subscribers_count"
        case forks = "forks_count"
        case stars = "stargazers_count"
        case size = "size"
        case archived = "archived"
        case disabled = "disabled"
        case fork = "fork"
        case homepage = "homepage"
        case about = "description"
        case created = "created_at"
        case updated = "updated_at"
        case pushed = "pushed_at"
    }

    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(id: try json[.id].decode(),
            owner: try json[.owner].decode(),
            name: try json[.name].decode(),
            license: try json[.license]?.decode(),
            topics: try json[.topics]?.decode() ?? [],
            master: try json[.master]?.decode(),
            watchers: try json[.watchers]?.decode(),
            forks: try json[.forks].decode(),
            stars: try json[.stars].decode(),
            size: try json[.size].decode(),
            archived: try json[.archived].decode(),
            disabled: try json[.disabled].decode(),
            fork: try json[.fork].decode(),
            homepage: try json[.homepage]?.decode(as: String.self) { $0.isEmpty ? nil : $0 },
            about: try json[.about]?.decode(as: String.self) { $0.isEmpty ? nil : $0 },
            created: try json[.created].decode(),
            updated: try json[.updated].decode(),
            pushed: try json[.pushed].decode())
    }
}
