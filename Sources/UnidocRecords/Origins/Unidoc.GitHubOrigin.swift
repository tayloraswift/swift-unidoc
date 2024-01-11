import BSON

extension Unidoc
{
    /// This type is largely the same as ``GitHub.Repo``, but with common fields extracted.
    @frozen public
    struct GitHubOrigin:Equatable, Sendable
    {
        public
        let id:Int32
        /// When the repository content (as opposed to its metadata) was last pushed to.
        /// This is usually different from ``updated``.
        public
        var pushed:BSON.Millisecond
        public
        var owner:String
        public
        var name:String

        public
        var homepage:String?
        public
        var about:String?

        public
        var watchers:Int
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
            pushed:BSON.Millisecond,
            owner:String,
            name:String,
            homepage:String?,
            about:String?,
            watchers:Int,
            size:Int,
            archived:Bool,
            disabled:Bool,
            fork:Bool)
        {
            self.id = id
            self.pushed = pushed
            self.owner = owner
            self.name = name
            self.homepage = homepage
            self.about = about
            self.watchers = watchers
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

        case homepage = "H"
        case about = "A"

        case watchers = "W"
        case size = "S"

        case archived = "X"
        case disabled = "D"
        case fork = "K"
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

        bson[.homepage] = self.homepage
        bson[.about] = self.about

        bson[.watchers] = self.watchers
        bson[.size] = self.size

        bson[.archived] = self.archived
        bson[.disabled] = self.disabled
        bson[.fork] = self.fork
    }
}
extension Unidoc.GitHubOrigin:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(),
            pushed: try bson[.pushed].decode(),
            owner: try bson[.owner].decode(),
            name: try bson[.name].decode(),
            homepage: try bson[.homepage]?.decode(),
            about: try bson[.about]?.decode(),
            watchers: try bson[.watchers].decode(),
            size: try bson[.size].decode(),
            archived: try bson[.archived].decode(),
            disabled: try bson[.disabled].decode(),
            fork: try bson[.fork].decode())
    }
}
