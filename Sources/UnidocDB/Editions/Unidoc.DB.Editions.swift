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
    let indexNonreleases:Mongo.CollectionIndex = .init("Nonreleases",
        unique: true)
    {
        $0[Unidoc.EditionMetadata[.package]] = (-)
        $0[Unidoc.EditionMetadata[.patch]] = (-)
        $0[Unidoc.EditionMetadata[.version]] = (-)
    }
        where:
    {
        $0[Unidoc.EditionMetadata[.series]] { $0[.eq] = Unidoc.VersionSeries.prerelease }
    }

    public static
    let indexReleases:Mongo.CollectionIndex = .init("Releases",
        unique: true)
    {
        $0[Unidoc.EditionMetadata[.package]] = (-)
        $0[Unidoc.EditionMetadata[.patch]] = (-)
        $0[Unidoc.EditionMetadata[.version]] = (-)
    }
        where:
    {
        $0[Unidoc.EditionMetadata[.series]] { $0[.eq] = Unidoc.VersionSeries.release }
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
            Self.indexNonreleases,
            Self.indexReleases,
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
