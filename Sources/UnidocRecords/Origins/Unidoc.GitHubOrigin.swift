import BSON
import GitHubAPI
import UnixTime

extension Unidoc
{
    /// This type is largely the same as ``GitHub.Repo``, but with common fields extracted.
    @frozen public
    struct GitHubOrigin:Equatable, Sendable
    {
        public
        let id:Int32
        public
        let owner:String
        public
        let name:String
        /// TODO: deoptionalize
        public
        let node:GitHub.Node?

        /// When the repository content (as opposed to its metadata) was last pushed to.
        /// This is usually different from ``PackageRepo.updated``.
        public
        var pushed:UnixMillisecond

        public
        var homepage:String?
        public
        var about:String?

        public
        var size:Int

        public
        var archived:Bool
        public
        var disabled:Bool
        public
        var fork:Bool

        @inlinable public
        init(id:Int32,
            owner:String,
            name:String,
            node:GitHub.Node?,
            pushed:UnixMillisecond,
            homepage:String?,
            about:String?,
            size:Int,
            archived:Bool,
            disabled:Bool,
            fork:Bool)
        {
            self.id = id
            self.pushed = pushed
            self.owner = owner
            self.name = name
            self.node = node
            self.homepage = homepage
            self.about = about
            self.size = size
            self.archived = archived
            self.disabled = disabled
            self.fork = fork
        }
    }
}
extension Unidoc.GitHubOrigin
{
    @inlinable public
    func https(token:GitHub.InstallationAccessToken) -> String
    {
        "https://x-access-token:\(token)@github.com/\(self.owner)/\(self.name)"
    }

    @inlinable public
    var https:String
    {
        "https://github.com/\(self.owner)/\(self.name)"
    }
}
extension Unidoc.GitHubOrigin
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case id = "I"
        case pushed = "P"
        case owner = "O"
        case name = "N"
        case node = "Q"

        case homepage = "H"
        case about = "A"

        @available(*, unavailable)
        case watchers = "W"

        case size = "S"

        case archived = "X"
        case disabled = "D"
        case fork = "K"

        @available(*, unavailable)
        case installation = "L"
    }
}
extension Unidoc.GitHubOrigin:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.pushed] = self.pushed
        bson[.owner] = self.owner
        bson[.name] = self.name
        bson[.node] = self.node

        bson[.homepage] = self.homepage
        bson[.about] = self.about

        bson[.size] = self.size

        bson[.archived] = self.archived
        bson[.disabled] = self.disabled
        bson[.fork] = self.fork
    }
}
extension Unidoc.GitHubOrigin:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(id: try bson[.id].decode(),
            owner: try bson[.owner].decode(),
            name: try bson[.name].decode(),
            node: try bson[.node]?.decode(),
            pushed: try bson[.pushed].decode(),
            homepage: try bson[.homepage]?.decode(),
            about: try bson[.about]?.decode(),
            size: try bson[.size].decode(),
            archived: try bson[.archived].decode(),
            disabled: try bson[.disabled].decode(),
            fork: try bson[.fork].decode())
    }
}
