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

        @usableFromInline
        let limit:Int
        @usableFromInline
        let user:Unidoc.User.ID?

        @inlinable public
        init(package symbol:Symbol.Package, limit:Int, user:Unidoc.User.ID? = nil)
        {
            self.symbol = symbol
            self.limit = limit
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
    typealias CollectionOrigin = UnidocDatabase.PackageAliases
    public
    typealias CollectionTarget = UnidocDatabase.Packages

    @inlinable public static
    var target:Mongo.KeyPath { Output[.package] }

    public
    func extend(pipeline:inout Mongo.PipelineEncoder)
    {
        if  let user:Unidoc.User.ID = self.user
        {
            pipeline[.lookup] = .init
            {
                $0[.from] = UnidocDatabase.Users.name
                $0[.pipeline] = .init
                {
                    $0[.match] = .init
                    {
                        $0[Unidoc.User[.id]] = user
                    }
                }
                $0[.as] = Output[.user]
            }

            //  Unbox single-element array.
            pipeline[.set] = .init
            {
                $0[Output[.user]] = .expr { $0[.first] = Output[.user] }
            }
        }

        //  Lookup the associated realm.
        pipeline[.lookup] = .init
        {
            $0[.from] = UnidocDatabase.Realms.name
            $0[.localField] = Self.target / Unidoc.PackageMetadata[.realm]
            $0[.foreignField] = Unidoc.RealmMetadata[.id]
            $0[.as] = Output[.realm]
        }

        //  Unbox single-element array.
        pipeline[.set] = .init
        {
            $0[Output[.realm]] = .expr { $0[.first] = Output[.realm] }
        }

        for release:Bool in [true, false]
        {
            pipeline[.lookup] = Mongo.LookupDocument.init
            {
                $0[.from] = UnidocDatabase.Editions.name
                $0[.localField] = Self.target / Unidoc.PackageMetadata[.id]
                $0[.foreignField] = Unidoc.EditionMetadata[.package]
                $0[.pipeline] = .init
                {
                    $0[.match] = .init
                    {
                        $0[Unidoc.EditionMetadata[.release]] = release
                        $0[Unidoc.EditionMetadata[.release]] = .init { $0[.exists] = true }
                    }

                    $0[.sort] = .init
                    {
                        $0[Unidoc.EditionMetadata[.patch]] = (-)
                        $0[Unidoc.EditionMetadata[.version]] = (-)
                    }

                    $0[.limit] = self.limit

                    $0[.replaceWith] = .init
                    {
                        $0[Tag[.edition]] = Mongo.Pipeline.ROOT
                    }

                    Self.load(&$0,
                        volume: Tag[.volume],
                        graph: Tag[.graph],
                        for: Tag[.edition] / Unidoc.EditionMetadata[.id])
                }
                $0[.as] = Output[release ? .releases : .prereleases]
            }
        }

        //  Compute id of local snapshot, if one were to exist.
        //  Only do this if the limit is greater than 1.
        guard self.limit > 1
        else
        {
            return
        }

        let tagless:Mongo.KeyPath = "_tagless"

        pipeline[.set] = .init
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

        Self.load(&pipeline,
            volume: Output[.tagless_volume],
            graph: Output[.tagless_graph],
            for: tagless)

        pipeline[.unset] = tagless
    }
}
extension Unidoc.VersionsQuery
{
    private static
    func load(_ pipeline:inout Mongo.PipelineEncoder,
        volume:Mongo.KeyPath,
        graph:Mongo.KeyPath,
        for id:Mongo.KeyPath)
    {
        //  Check if a volume has been created for this edition.
        pipeline[.lookup] = .init
        {
            $0[.from] = UnidocDatabase.Volumes.name
            $0[.localField] = id
            $0[.foreignField] = Unidoc.VolumeMetadata[.id]
            $0[.as] = volume
        }

        //  Check if a symbol graph has been uploaded for this edition.
        pipeline[.lookup] = Mongo.LookupDocument.init
        {
            $0[.from] = UnidocDatabase.Snapshots.name
            $0[.localField] = id
            $0[.foreignField] = Unidoc.Snapshot[.id]
            $0[.pipeline] = .init
            {
                $0[.replaceWith] = .init
                {
                    $0[Graph[.uplinking]] = .expr
                    {
                        $0[.coalesce] = (Unidoc.Snapshot[.uplinking], false)
                    }
                    $0[Graph[.bytes]] = .expr
                    {
                        $0[.objectSize] = Unidoc.Snapshot[.graph]
                    }
                    $0[Graph[.abi]] = Unidoc.Snapshot[.metadata] / SymbolGraphMetadata[.abi]

                }
            }
            $0[.as] = graph
        }

        //  Unbox single-element arrays.
        pipeline[.set] = .init
        {
            $0[volume] = .expr { $0[.first] = volume }
            $0[graph] = .expr { $0[.first] = graph }
        }
    }
}
