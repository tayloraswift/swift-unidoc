import BSON
import UnixTime

extension Unidoc
{
    @frozen public
    struct PackageRepo:Sendable
    {
        /// When the package’s repo information was last read. This is always non-nil because
        /// crawling is how we obtain this structure in the first place.
        public
        var crawled:BSON.Millisecond
        /// When the package’s tags were last fetched. Nil if the package’s tags have not been
        /// read yet.
        public
        var fetched:BSON.Millisecond?
        /// When we should fetch the package’s tags again. This is nil in some cases where we
        /// do not want to crawl the package at all, such as when the package is archived or
        /// unfree.
        ///
        /// Packages that we want to crawl frequently will expire instantly – that is, they
        /// have an expiration equal to ``fetched``.
        ///
        /// Even if this becomes nil, it is expected that a small number of packages may again
        /// be rediscovered later and ruled eligible for crawling.
        public
        var expires:BSON.Millisecond?

        /// The account that owns the repo, and could be reasonably allowed to update its
        /// package settings.
        public
        var account:Unidoc.Account?

        /// When the repo was created. Both GitHub and GitLab define this field.
        ///
        /// For query convenience, the instant always encodes an integral date.
        /// This field is used as a quasi shard key for administative purposes.
        public
        var created:BSON.Millisecond
        /// When the repo was last updated. Both GitHub and GitLab define this field.
        ///
        /// The instant represents the time the repo metadata was last updated, not the time
        /// the repo content was last updated. The instant may contain a fractional time
        /// component.
        public
        var updated:BSON.Millisecond

        /// The repo’s license. All software repos have the concept of a license.
        public
        var license:PackageLicense?
        /// The repo’s topic memberships. Both GitHub and GitLab have topics.
        public
        var topics:[String]
        /// The repo’s master branch. All Git repos have the concept of a master branch.
        public
        var master:String

        /// Information specific to the repo’s hosting provider.
        public
        var origin:PackageOrigin
        /// The number of forks this repo has. Both GitHub and GitLab count forks.
        public
        var forks:Int
        /// The number of stars this repo has. Both GitHub and GitLab count stars.
        public
        var stars:Int

        @inlinable public
        init(
            crawled:BSON.Millisecond,
            fetched:BSON.Millisecond?,
            expires:BSON.Millisecond?,
            account:Unidoc.Account?,
            created:BSON.Millisecond,
            updated:BSON.Millisecond,
            license:PackageLicense?,
            topics:[String],
            master:String,
            origin:PackageOrigin,
            forks:Int = 0,
            stars:Int = 0)
        {
            self.crawled = crawled
            self.fetched = fetched
            self.expires = expires
            self.account = account

            self.created = created
            self.updated = updated
            self.license = license
            self.topics = topics
            self.master = master
            self.origin = origin
            self.forks = forks
            self.stars = stars
        }
    }
}
extension Unidoc.PackageRepo
{
    @available(*, deprecated, renamed: "Unidoc.PackageOrigin")
    public
    typealias AnyOrigin = Unidoc.PackageOrigin

    @available(*, deprecated, renamed: "Unidoc.GitHubOrigin")
    public
    typealias GitHubOrigin = Unidoc.GitHubOrigin
}
extension Unidoc.PackageRepo
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case crawled = "I"
        case fetched = "G"
        case expires = "E"
        case account = "A"

        case created = "C"
        case updated = "U"

        case license = "L"
        case topics = "T"
        case master = "M"

        case github = "H"

        case forks = "F"
        case stars = "S"
    }
}
extension Unidoc.PackageRepo:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.crawled] = self.crawled
        bson[.fetched] = self.fetched
        bson[.expires] = self.expires
        bson[.account] = self.account
        bson[.created] = self.created
        bson[.updated] = self.updated

        bson[.license] = self.license
        bson[.topics] = self.topics.isEmpty ? nil : self.topics
        bson[.master] = self.master

        switch self.origin
        {
        case .github(let origin):   bson[.github] = origin
        }

        bson[.forks] = self.forks
        bson[.stars] = self.stars
    }
}
extension Unidoc.PackageRepo:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        let origin:Unidoc.PackageOrigin = .github(try bson[.github].decode())

        self.init( // TODO: deoptionalize
            crawled: try bson[.crawled]?.decode() ?? 0,
            fetched: try bson[.fetched]?.decode(),
            expires: try bson[.expires]?.decode(),
            account: try bson[.account]?.decode(),
            created: try bson[.created].decode(),
            updated: try bson[.updated].decode(),
            license: try bson[.license]?.decode(),
            topics: try bson[.topics]?.decode() ?? [],
            master: try bson[.master].decode(),
            origin: origin,
            forks: try bson[.forks].decode(),
            stars: try bson[.stars].decode())
    }
}
