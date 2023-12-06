import BSON
import GitHubAPI
import MongoQL
import UnidocRecords

@available(*, deprecated, renamed: "Unidex.Package.Repo")
public
typealias PackageRepo = Unidex.Package.Repo

extension Unidex
{
    @available(*, deprecated, renamed: "Unidex.Package.Repo")
    public
    typealias Repo = Package.Repo
}
extension Unidex.Package
{
    @frozen public
    enum Repo:Equatable, Sendable
    {
        case github(GitHub.Repo)
    }
}
extension Unidex.Package.Repo
{
    @inlinable public
    var origin:Origin
    {
        switch self
        {
        case .github(let repo): return .github(repo.owner.login, repo.name)
        }
    }

    var visibleInFeed:Bool
    {
        switch self
        {
        case .github(let repo): repo.visibleInFeed
        }
    }
}
extension Unidex.Package.Repo:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        /// The repo’s default branch.
        case master = "M"

        /// The id field for GitHub repos.
        case github = "h"

        case github_owner = "hO"
        case github_name = "hN"
        case github_license = "hL"
        case github_topics = "hT"
        case github_watchers = "hW"
        case github_forks = "hF"
        case github_stars = "hZ"
        case github_size = "hS"
        case github_archived = "hX"
        case github_disabled = "hD"
        case github_fork = "hK"
        case github_homepage = "hH"
        case github_about = "hA"
        case github_created = "hC"
        case github_updated = "hU"
        case github_pushed = "hP"
    }
}
extension Unidex.Package.Repo:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        switch self
        {
        case .github(let repo):
            bson[.master] = repo.master
            bson[.github] = repo.id

            bson[.github_owner] = repo.owner
            bson[.github_name] = repo.name
            bson[.github_license] = repo.license
            bson[.github_topics] = repo.topics.isEmpty ? nil : repo.topics
            bson[.github_watchers] = repo.watchers
            bson[.github_forks] = repo.forks
            bson[.github_stars] = repo.stars
            bson[.github_size] = repo.size
            bson[.github_archived] = repo.archived
            bson[.github_disabled] = repo.disabled
            bson[.github_fork] = repo.fork
            bson[.github_homepage] = repo.homepage
            bson[.github_about] = repo.about
            bson[.github_created] = repo.created
            bson[.github_updated] = repo.updated
            bson[.github_pushed] = repo.pushed
        }
    }
}
extension Unidex.Package.Repo:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        let master:String = try bson[.master].decode()

        do
        {
            /// Right now only GitHub repos are supported, but eventually we’ll want to
            /// represent other kinds of repos with this type.
            let id:Int32 = try bson[.github].decode()

            self = .github(.init(id: id,
                owner: try bson[.github_owner].decode(),
                name: try bson[.github_name].decode(),
                license: try bson[.github_license]?.decode(),
                topics: try bson[.github_topics]?.decode() ?? [],
                master: master,
                watchers: try bson[.github_watchers].decode(),
                forks: try bson[.github_forks].decode(),
                stars: try bson[.github_stars].decode(),
                size: try bson[.github_size].decode(),
                archived: try bson[.github_archived].decode(),
                disabled: try bson[.github_disabled].decode(),
                fork: try bson[.github_fork].decode(),
                homepage: try bson[.github_homepage]?.decode(),
                about: try bson[.github_about]?.decode(),
                created: try bson[.github_created].decode(),
                updated: try bson[.github_updated].decode(),
                pushed: try bson[.github_pushed].decode()))
        }
    }
}
