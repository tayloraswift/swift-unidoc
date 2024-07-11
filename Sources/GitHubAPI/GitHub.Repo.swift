import JSON

extension GitHub
{
    @frozen public
    struct Repo:Identifiable, Equatable, Sendable
    {
        public
        let id:Int32

        public
        let owner:Owner
        public
        let name:String
        public
        let node:Node

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

        /// The repo’s visibility on GitHub. Some queries return only public repositories and so
        /// omit this field.
        public
        var visibility:RepoVisibility?
        /// The repo’s dominant language, if GitHub was able to detect one.
        public
        var language:String?
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
            node:Node,
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
            visibility:RepoVisibility? = nil,
            language:String? = nil,
            homepage:String? = nil,
            about:String? = nil,
            created:String,
            updated:String,
            pushed:String)
        {
            self.id = id
            self.owner = owner
            self.name = name
            self.node = node
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
            self.visibility = visibility
            self.language = language
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
        case node_id

        case owner
        case name
        case license
        case topics
        case default_branch
        // not `watchers_count`, which is just stargazers
        case subscribers_count
        case forks_count
        case stargazers_count
        case size
        case archived
        case disabled
        case fork
        case visibility
        case language
        case homepage
        case description
        case created_at
        case updated_at
        case pushed_at
    }

    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        //  Note: GitHub often returns explicit `null` values for fields that are missing.
        //  This means we need to be careful when mapping optional fields, particularly through
        //  the use `as:`.
        self.init(id: try json[.id].decode(),
            owner: try json[.owner].decode(),
            name: try json[.name].decode(),
            node: try json[.node_id].decode(),
            license: try json[.license]?.decode(),
            topics: try json[.topics]?.decode() ?? [],
            master: try json[.default_branch]?.decode(),
            watchers: try json[.subscribers_count]?.decode(),
            forks: try json[.forks_count].decode(),
            stars: try json[.stargazers_count].decode(),
            size: try json[.size].decode(),
            archived: try json[.archived].decode(),
            disabled: try json[.disabled].decode(),
            fork: try json[.fork].decode(),
            visibility: try json[.visibility]?.decode(),
            language: try json[.language]?.decode(),
            homepage: try json[.homepage]?.decode(),
            about: try json[.description]?.decode(),
            created: try json[.created_at].decode(),
            updated: try json[.updated_at].decode(),
            pushed: try json[.pushed_at].decode())

        //  String field normalization.
        if  case true? = self.homepage?.isEmpty
        {
            self.homepage = nil
        }
        if  case true? = self.about?.isEmpty
        {
            self.about = nil
        }
    }
}
