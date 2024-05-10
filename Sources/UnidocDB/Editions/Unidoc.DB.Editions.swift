import BSON
import GitHubAPI
import JSONEncoding
import MongoDB
import SemanticVersions
import SHA1
import UnidocRecords

extension Unidoc.DB
{
    @frozen public
    struct Editions
    {
        public
        let database:Mongo.Database

        @inlinable internal
        init(database:Mongo.Database)
        {
            self.database = database
        }
    }
}
extension Unidoc.DB.Editions
{
    public static
    let indexEditionName:Mongo.CollectionIndex = .init("EditionName",
        collation: SimpleCollation.spec,
        unique: true)
    {
        $0[Unidoc.EditionMetadata[.package]] = (+)
        $0[Unidoc.EditionMetadata[.name]] = (+)
    }

    public static
    let indexEditionCoordinate:Mongo.CollectionIndex = .init("EditionCoordinate",
        unique: true)
    {
        $0[Unidoc.EditionMetadata[.package]] = (-)
        $0[Unidoc.EditionMetadata[.version]] = (-)
    }

    public static
    let indexPrereleases:Mongo.CollectionIndex = .init("Prereleases",
        unique: true)
    {
        $0[Unidoc.EditionMetadata[.package]] = (-)
        $0[Unidoc.EditionMetadata[.semver]] = (-)
        $0[Unidoc.EditionMetadata[.version]] = (-)
    }
        where:
    {
        $0[Unidoc.EditionMetadata[.semver]] { $0[.exists] = true }
        $0[Unidoc.EditionMetadata[.release]] = false
    }

    public static
    let indexReleases:Mongo.CollectionIndex = .init("Releases",
        unique: true)
    {
        $0[Unidoc.EditionMetadata[.package]] = (-)
        $0[Unidoc.EditionMetadata[.semver]] = (-)
        $0[Unidoc.EditionMetadata[.version]] = (-)
    }
        where:
    {
        $0[Unidoc.EditionMetadata[.release]] = true
    }

    public static
    let indexBranches:Mongo.CollectionIndex = .init("Branches",
        unique: true)
    {
        $0[Unidoc.EditionMetadata[.package]] = (+)
        $0[Unidoc.EditionMetadata[.name]] = (+)
    }
        where:
    {
        //  No better way to specify `$0[.exists] = false`
        $0[Unidoc.EditionMetadata[.semver]] = BSON.Null.init()
        $0[Unidoc.EditionMetadata[.release]] = false
    }
}
extension Unidoc.DB.Editions:Mongo.CollectionModel
{
    public
    typealias Element = Unidoc.EditionMetadata

    @inlinable public static
    var name:Mongo.Collection { "Editions" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex]
    {
        [
            Self.indexEditionName,
            Self.indexEditionCoordinate,
            Self.indexPrereleases,
            Self.indexReleases,
            Self.indexBranches,
        ]
    }
}
extension Unidoc.DB.Editions:Mongo.RecodableModel
{
    public
    func recode(with session:Mongo.Session) async throws -> (modified:Int, of:Int)
    {
        try await self.recode(through: Unidoc.EditionMetadata.self,
            with: session,
            by: .now.advanced(by: .seconds(60)))
    }
}
