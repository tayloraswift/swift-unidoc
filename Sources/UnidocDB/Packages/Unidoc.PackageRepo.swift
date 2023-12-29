import BSON
import GitHubAPI
import MongoQL
import UnixTime

extension Unidoc
{
    @frozen public
    struct PackageRepo:Equatable, Sendable
    {
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
        var origin:AnyOrigin
        /// The number of forks this repo has. Both GitHub and GitLab count forks.
        public
        var forks:Int
        /// The number of stars this repo has. Both GitHub and GitLab count stars.
        public
        var stars:Int

        @inlinable public
        init(
            created:BSON.Millisecond,
            updated:BSON.Millisecond,
            license:PackageLicense?,
            topics:[String],
            master:String,
            origin:AnyOrigin,
            forks:Int = 0,
            stars:Int = 0)
        {
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
    @inlinable public static
    func github(_ repo:GitHub.Repo) throws -> Self
    {
        guard
        let created:Timestamp.Components = .init(iso8601: repo.created),
        let created:UnixInstant = .init(utc: .date(created))
        else
        {
            throw GitHubTimestampError.created(repo.created)
        }

        guard
        let updated:Timestamp.Components = .init(iso8601: repo.updated),
        let updated:UnixInstant = .init(utc: updated)
        else
        {
            throw GitHubTimestampError.updated(repo.updated)
        }

        guard
        let pushed:Timestamp.Components = .init(iso8601: repo.pushed),
        let pushed:UnixInstant = .init(utc: pushed)
        else
        {
            throw GitHubTimestampError.pushed(repo.pushed)
        }

        return .init(
            created: .init(created),
            updated: .init(updated),
            license: repo.license.map { .init(spdx: $0.id, name: $0.name) },
            topics: repo.topics,
            master: repo.master,
            origin: .github(.init(
                id: repo.id,
                pushed: .init(pushed),
                owner: repo.owner.login,
                name: repo.name,
                homepage: repo.homepage,
                about: repo.about,
                watchers: repo.watchers,
                size: repo.size,
                archived: repo.archived,
                disabled: repo.disabled,
                fork: repo.fork)),
            forks: repo.forks,
            stars: repo.stars)
    }
}
extension Unidoc.PackageRepo:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
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
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        let origin:AnyOrigin = .github(try bson[.github].decode())

        self.init(
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
