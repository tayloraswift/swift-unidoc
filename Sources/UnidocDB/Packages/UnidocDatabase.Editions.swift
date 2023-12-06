import BSON
import GitHubAPI
import JSONEncoding
import MongoDB
import SemanticVersions
import SHA1
import UnidocRecords

extension UnidocDatabase
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
extension UnidocDatabase.Editions
{
    public static
    let indexEditionName:Mongo.CollectionIndex = .init("EditionName",
        collation: SimpleCollation.spec,
        unique: true)
    {
        $0[Unidex.Edition[.package]] = (+)
        $0[Unidex.Edition[.name]] = (+)
    }

    public static
    let indexEditionCoordinate:Mongo.CollectionIndex = .init("EditionCoordinate",
        unique: true)
    {
        $0[Unidex.Edition[.package]] = (-)
        $0[Unidex.Edition[.version]] = (-)
    }

    public static
    let indexNonreleases:Mongo.CollectionIndex = .init("Nonreleases",
        unique: true)
    {
        $0[Unidex.Edition[.package]] = (-)
        $0[Unidex.Edition[.patch]] = (-)
        $0[Unidex.Edition[.version]] = (-)
    }
        where:
    {
        $0[Unidex.Edition[.release]] = .init { $0[.eq] = false }
    }

    public static
    let indexReleases:Mongo.CollectionIndex = .init("Releases",
        unique: true)
    {
        $0[Unidex.Edition[.package]] = (-)
        $0[Unidex.Edition[.patch]] = (-)
        $0[Unidex.Edition[.version]] = (-)
    }
        where:
    {
        $0[Unidex.Edition[.release]] = .init { $0[.eq] = true }
    }
}
extension UnidocDatabase.Editions:Mongo.CollectionModel
{
    public
    typealias Element = Unidex.Edition

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
extension UnidocDatabase.Editions:Mongo.RecodableModel
{
    public
    func recode(with session:Mongo.Session) async throws -> (modified:Int, of:Int)
    {
        try await self.recode(through: Unidex.Edition.self,
            with: session,
            by: .now.advanced(by: .seconds(60)))
    }
}
