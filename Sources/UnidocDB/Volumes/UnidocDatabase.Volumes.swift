import MongoDB
import MongoQL
import Symbols
import Unidoc
import UnidocRecords

extension UnidocDatabase
{
    @frozen public
    struct Volumes
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
extension UnidocDatabase.Volumes
{
    public static
    let indexCoordinateLatest:Mongo.CollectionIndex = .init("CoordinateLatest",
        unique: true)
    {
        $0[Unidoc.VolumeMetadata[.id]] = (+)
        $0[Unidoc.VolumeMetadata[.latest]] = (-)
    }

    public static
    let indexCoordinatePatch:Mongo.CollectionIndex = .init("CoordinatePatch",
        unique: true)
    {
        $0[Unidoc.VolumeMetadata[.id]] = (+)
        $0[Unidoc.VolumeMetadata[.patch]] = (-)
    }
        where:
    {
        $0[Unidoc.VolumeMetadata[.patch]] = .init { $0[.exists] = true }
    }

    public static
    let indexSymbolicPatch:Mongo.CollectionIndex = .init("SymbolicPatch",
        collation: VolumeCollation.spec,
        unique: true)
    {
        $0[Unidoc.VolumeMetadata[.package]] = (+)
        $0[Unidoc.VolumeMetadata[.patch]] = (-)
    }
        where:
    {
        $0[Unidoc.VolumeMetadata[.patch]] = .init { $0[.exists] = true }
    }

    public static
    let indexSymbolic:Mongo.CollectionIndex = .init("Symbolic",
        collation: VolumeCollation.spec,
        unique: true)
    {
        $0[Unidoc.VolumeMetadata[.package]] = (+)
        $0[Unidoc.VolumeMetadata[.version]] = (+)
    }

    public static
    let indexRealm:Mongo.CollectionIndex = .init("Realm",
        unique: false)
    {
        $0[Unidoc.VolumeMetadata[.realm]] = (+)
    }
        where:
    {
        $0[Unidoc.VolumeMetadata[.realm]] = .init { $0[.exists] = true }
    }
}
extension UnidocDatabase.Volumes:Mongo.CollectionModel
{
    public
    typealias Element = Unidoc.VolumeMetadata

    @inlinable public static
    var name:Mongo.Collection { "Volumes" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex]
    {
        [
            Self.indexCoordinateLatest,
            Self.indexCoordinatePatch,
            Self.indexSymbolicPatch,
            Self.indexSymbolic,
            Self.indexRealm,
        ]
    }
}
extension UnidocDatabase.Volumes:Mongo.RecodableModel
{
    public
    func recode(with session:Mongo.Session) async throws -> (modified:Int, of:Int)
    {
        try await self.recode(through: Unidoc.VolumeMetadata.self,
            with: session,
            by: .now.advanced(by: .seconds(30)))
    }
}
extension UnidocDatabase.Volumes
{
    func find(named symbol:Symbol.Edition,
        with session:Mongo.Session) async throws -> Unidoc.VolumeMetadata?
    {
        try await session.run(
            command: Mongo.Find<Mongo.Single<Unidoc.VolumeMetadata>>.init(Self.name,
                limit: 1)
            {
                $0[.collation] = VolumeCollation.spec
                $0[.filter] = .init
                {
                    $0[Unidoc.VolumeMetadata[.package]] = symbol.package
                    $0[Unidoc.VolumeMetadata[.version]] = symbol.version
                }
                $0[.hint] = .init
                {

                    $0[Unidoc.VolumeMetadata[.package]] = (+)
                    $0[Unidoc.VolumeMetadata[.version]] = (+)
                }
            },
            against: self.database)
    }
}
extension UnidocDatabase.Volumes
{
    /// Returns the latest release version of the specified package, if one exists.
    func latestRelease(of package:Unidoc.Package,
        with session:Mongo.Session) async throws -> PatchView?
    {
        let results:[PatchView] = try await session.run(
            command: self.latestRelease(of: package),
            against: self.database)
        return results.first
    }

    private
    func latestRelease(of package:Unidoc.Package) -> Mongo.Find<Mongo.SingleBatch<PatchView>>
    {
        .init(Self.name, limit: 1)
        {
            $0[.filter] = .init
            {
                $0[.and] = .init
                {
                    let cell:ClosedRange<Unidoc.Edition> = .package(package)

                    $0.append
                    {
                        $0[Unidoc.VolumeMetadata[.patch]] = .init { $0[.exists] = true }
                    }
                    $0.append
                    {
                        $0[Unidoc.VolumeMetadata[.id]] = .init { $0[.gte] = cell.lowerBound }
                    }
                    $0.append
                    {
                        $0[Unidoc.VolumeMetadata[.id]] = .init { $0[.lte] = cell.upperBound }
                    }
                }
            }
            $0[.sort] = .init
            {
                $0[Unidoc.VolumeMetadata[.patch]] = (-)
            }
            $0[.hint] = .init
            {
                $0[Unidoc.VolumeMetadata[.id]] = (+)
                $0[Unidoc.VolumeMetadata[.patch]] = (-)
            }
            $0[.projection] = .init
            {
                $0[Unidoc.VolumeMetadata[.id]] = true
                $0[Unidoc.VolumeMetadata[.patch]] = true
            }
        }
    }
}
