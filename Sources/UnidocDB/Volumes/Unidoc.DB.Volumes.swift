import MongoDB
import MongoQL
import Symbols
import Unidoc
import UnidocRecords

extension Unidoc.DB
{
    @frozen public
    struct Volumes
    {
        public
        let database:Mongo.Database
        public
        let session:Mongo.Session

        @inlinable
        init(database:Mongo.Database, session:Mongo.Session)
        {
            self.database = database
            self.session = session
        }
    }
}
extension Unidoc.DB.Volumes
{
    public
    static let indexCoordinatePatch:Mongo.CollectionIndex = .init("CoordinatePatch",
        unique: true)
    {
        $0[Unidoc.VolumeMetadata[.id]] = (+)
        $0[Unidoc.VolumeMetadata[.patch]] = (-)
    }
        where:
    {
        $0[Unidoc.VolumeMetadata[.patch]] { $0[.exists] = true }
    }

    public
    static let indexSymbolicPatch:Mongo.CollectionIndex = .init("SymbolicPatch",
        collation: .casefolding,
        unique: true)
    {
        $0[Unidoc.VolumeMetadata[.package]] = (+)
        $0[Unidoc.VolumeMetadata[.patch]] = (-)
    }
        where:
    {
        $0[Unidoc.VolumeMetadata[.patch]] { $0[.exists] = true }
    }

    public
    static let indexSymbolic:Mongo.CollectionIndex = .init("Symbolic",
        collation: .casefolding,
        unique: true)
    {
        $0[Unidoc.VolumeMetadata[.package]] = (+)
        $0[Unidoc.VolumeMetadata[.version]] = (+)
    }

    public
    static let indexRealm:Mongo.CollectionIndex = .init("Realm",
        unique: false)
    {
        $0[Unidoc.VolumeMetadata[.realm]] = (+)
    }
        where:
    {
        $0[Unidoc.VolumeMetadata[.realm]] { $0[.exists] = true }
    }

    public
    static let indexLatestFlag:Mongo.CollectionIndex = .init("LatestFlag",
        unique: true)
    {
        $0[Unidoc.VolumeMetadata[.latest]] = (+)
        $0[Unidoc.VolumeMetadata[.id]] = (+)
    }

}
extension Unidoc.DB.Volumes:Mongo.CollectionModel
{
    public
    typealias Element = Unidoc.VolumeMetadata

    @inlinable public static
    var name:Mongo.Collection { "Volumes" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex]
    {
        [
            Self.indexCoordinatePatch,
            Self.indexSymbolicPatch,
            Self.indexSymbolic,
            Self.indexRealm,
            Self.indexLatestFlag,
        ]
    }
}
extension Unidoc.DB.Volumes:Mongo.RecodableModel
{
}
extension Unidoc.DB.Volumes
{
    func find(named symbol:Symbol.Volume) async throws -> Unidoc.VolumeMetadata?
    {
        try await session.run(
            command: Mongo.Find<Mongo.Single<Unidoc.VolumeMetadata>>.init(Self.name,
                limit: 1)
            {
                $0[.collation] = .casefolding
                $0[.filter]
                {
                    $0[Unidoc.VolumeMetadata[.package]] = symbol.package
                    $0[Unidoc.VolumeMetadata[.version]] = symbol.version
                }
                $0[.hint]
                {
                    $0[Unidoc.VolumeMetadata[.package]] = (+)
                    $0[Unidoc.VolumeMetadata[.version]] = (+)
                }
            },
            against: self.database)
    }
}
extension Unidoc.DB.Volumes
{
    /// Returns the latest release version of the specified package, if one exists.
    func latestRelease(of package:Unidoc.Package) async throws -> PatchView?
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
            $0[.filter]
            {
                $0[.and]
                {
                    let cell:ClosedRange<Unidoc.Edition> = .package(package)

                    $0
                    {
                        $0[Unidoc.VolumeMetadata[.patch]] { $0[.exists] = true }
                    }
                    $0
                    {
                        $0[Unidoc.VolumeMetadata[.id]] { $0[.gte] = cell.lowerBound }
                    }
                    $0
                    {
                        $0[Unidoc.VolumeMetadata[.id]] { $0[.lte] = cell.upperBound }
                    }
                }
            }
            $0[.sort]
            {
                $0[Unidoc.VolumeMetadata[.patch]] = (-)
            }
            $0[.hint]
            {
                $0[Unidoc.VolumeMetadata[.id]] = (+)
                $0[Unidoc.VolumeMetadata[.patch]] = (-)
            }
            $0[.projection]
            {
                $0[Unidoc.VolumeMetadata[.id]] = true
                $0[Unidoc.VolumeMetadata[.patch]] = true
            }
        }
    }
}
