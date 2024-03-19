import BSON
import MongoDB
import MongoQL
import SymbolGraphs
import Symbols
import UnidocDB
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct VersionsQuery:Equatable, Hashable, Sendable
    {
        public
        let symbol:Symbol.Package
        public
        let filter:VersionsPredicate
        public
        let user:Unidoc.Account?

        @inlinable public
        init(symbol:Symbol.Package, filter:VersionsPredicate, as user:Unidoc.Account? = nil)
        {
            self.symbol = symbol
            self.filter = filter
            self.user = user
        }
    }
}
extension Unidoc.VersionsQuery:Mongo.PipelineQuery
{
    public
    typealias Iteration = Mongo.Single<Output>
}
extension Unidoc.VersionsQuery:Unidoc.AliasingQuery
{
    public
    typealias CollectionOrigin = Unidoc.DB.PackageAliases
    public
    typealias CollectionTarget = Unidoc.DB.Packages

    @inlinable public static
    var target:Mongo.AnyKeyPath { Output[.package] }

    public
    func extend(pipeline:inout Mongo.PipelineEncoder)
    {
        switch self.filter
        {
        case .tags(limit: let limit, page: let page, beta: let beta):
            Self.loadTagged(releases: !beta,
                limit: limit,
                skip: limit * page,
                with: &pipeline)

        case .none(limit: let limit):
            Self.loadPackageConfiguration(with: &pipeline)
            Self.loadTagless(with: &pipeline)

            Self.loadTagged(releases: false, limit: limit, with: &pipeline)
            Self.loadTagged(releases: true, limit: limit, with: &pipeline)
        }

        if  let user:Unidoc.Account = self.user
        {
            //  Lookup the querying user.
            pipeline[stage: .lookup] = .init
            {
                $0[.from] = Unidoc.DB.Users.name
                $0[.pipeline] = .init
                {
                    $0[stage: .match] = .init
                    {
                        $0[Unidoc.User[.id]] = user
                    }
                }
                $0[.as] = Output[.user]
            }

            //  Unbox single-element array.
            pipeline[stage: .set] = .init
            {
                $0[Output[.user]] = .expr { $0[.first] = Output[.user] }
            }
        }
    }
}
extension Unidoc.VersionsQuery
{
    private static
    func loadTagged(releases:Bool,
        limit:Int,
        skip:Int = 0,
        with pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline[stage: .lookup] = Mongo.LookupDocument.init
        {
            $0[.from] = Unidoc.DB.Editions.name
            $0[.localField] = Self.target / Unidoc.PackageMetadata[.id]
            $0[.foreignField] = Unidoc.EditionMetadata[.package]
            $0[.pipeline] = .init
            {
                $0[stage: .match] = .init
                {
                    $0[Unidoc.EditionMetadata[.release]] = releases
                    $0[Unidoc.EditionMetadata[.release]] { $0[.exists] = true }
                }

                $0[stage: .sort] = .init
                {
                    $0[Unidoc.EditionMetadata[.patch]] = (-)
                    $0[Unidoc.EditionMetadata[.version]] = (-)
                }

                $0[stage: .skip] = skip == 0 ? nil : skip

                $0[stage: .limit] = limit

                $0[stage: .replaceWith] = .init
                {
                    $0[Tag[.edition]] = Mongo.Pipeline.ROOT
                }

                Self.loadResources(associatedTo: Tag[.edition] / Unidoc.EditionMetadata[.id],
                    volume: Tag[.volume],
                    graph: Tag[.graph],
                    with: &$0)
            }
            $0[.as] = Output[releases ? .releases : .prereleases]
        }
    }

    private static
    func loadTagless(with pipeline:inout Mongo.PipelineEncoder)
    {
        //  Compute id of local snapshot, if one were to exist.
        let tagless:Mongo.AnyKeyPath = "_tagless"

        pipeline[stage: .set] = .init
        {
            $0[tagless] = .expr
            {
                $0[.add] = .init
                {
                    $0.expr
                    {
                        $0[.multiply] =
                        (
                            Self.target / Unidoc.PackageMetadata[.id],
                            0x0000_0001_0000_0000 as Int64
                        )
                    }
                    $0.append(0x0000_0000_ffff_ffff as Int64)
                }
            }
        }

        Self.loadResources(associatedTo: tagless,
            volume: Output[.tagless_volume],
            graph: Output[.tagless_graph],
            with: &pipeline)

        pipeline[stage: .unset] = tagless
    }

    private static
    func loadPackageConfiguration(with pipeline:inout Mongo.PipelineEncoder)
    {
        //  Lookup other aliases for this package.
        let aliases:Mongo.List<Unidoc.PackageAlias, Mongo.AnyKeyPath> = .init(
            in: Output[.aliases])

        pipeline[stage: .lookup] = .init
        {
            $0[.from] = Unidoc.DB.PackageAliases.name
            $0[.localField] = Self.target / Unidoc.PackageMetadata[.id]
            $0[.foreignField] = Unidoc.PackageAlias[.coordinate]
            $0[.as] = aliases.expression
        }

        pipeline[stage: .set] = .init
        {
            $0[Output[.aliases]] = .expr { $0[.map] = aliases.map { $0[.id] } }
        }

        //  Lookup the associated realm.
        pipeline[stage: .lookup] = .init
        {
            $0[.from] = Unidoc.DB.Realms.name
            $0[.localField] = Self.target / Unidoc.PackageMetadata[.realm]
            $0[.foreignField] = Unidoc.RealmMetadata[.id]
            $0[.as] = Output[.realm]
        }
        //  Unbox single-element array.
        pipeline[stage: .set] = .init
        {
            $0[Output[.realm]] = .expr { $0[.first] = Output[.realm] }
        }
    }
}
extension Unidoc.VersionsQuery
{
    /// Load information about any associated documentation volume or symbol graph for a
    /// particular package edition.
    private static
    func loadResources(associatedTo id:Mongo.AnyKeyPath,
        volume:Mongo.AnyKeyPath,
        graph:Mongo.AnyKeyPath,
        with pipeline:inout Mongo.PipelineEncoder)
    {
        //  Check if a volume has been created for this edition.
        pipeline[stage: .lookup] = .init
        {
            $0[.from] = Unidoc.DB.Volumes.name
            $0[.localField] = id
            $0[.foreignField] = Unidoc.VolumeMetadata[.id]
            $0[.as] = volume
        }

        //  Check if a symbol graph has been uploaded for this edition.
        pipeline[stage: .lookup] = Mongo.LookupDocument.init
        {
            $0[.from] = Unidoc.DB.Snapshots.name
            $0[.localField] = id
            $0[.foreignField] = Unidoc.Snapshot[.id]
            $0[.pipeline] = .init
            {
                $0[stage: .replaceWith] = .init
                {
                    $0[Graph[.id]] = Unidoc.Snapshot[.id]
                    $0[Graph[.inlineBytes]] = .expr
                    {
                        $0[.objectSize] = .expr
                        {
                            $0[.coalesce] = (Unidoc.Snapshot[.inline], BSON.Null.init())
                        }
                    }
                    $0[Graph[.remoteBytes]] = .expr
                    {
                        $0[.coalesce] = (Unidoc.Snapshot[.size], 0)
                    }
                    $0[Graph[.action]] = Unidoc.Snapshot[.action]
                    $0[Graph[.abi]] = Unidoc.Snapshot[.metadata] / SymbolGraphMetadata[.abi]
                }
            }
            $0[.as] = graph
        }

        //  Unbox single-element arrays.
        pipeline[stage: .set] = .init
        {
            $0[volume] = .expr { $0[.first] = volume }
            $0[graph] = .expr { $0[.first] = graph }
        }
    }
}
