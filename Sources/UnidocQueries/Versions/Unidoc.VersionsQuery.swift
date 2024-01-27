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
    enum VersionsQuery:Equatable, Hashable, Sendable
    {
        case latest(Symbol.Package)
        case tags(Symbol.Package, limit:Int, user:Unidoc.User.ID? = nil)
    }
}
extension Unidoc.VersionsQuery
{
    private
    var limit:Int
    {
        switch self
        {
        case .latest:                   1
        case .tags(_, let limit, _):    limit
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
    var target:Mongo.KeyPath { Output[.package] }

    @inlinable public
    var symbol:Symbol.Package
    {
        switch self
        {
        case .latest(let symbol):       symbol
        case .tags(let symbol, _, _):   symbol
        }
    }

    public
    func extend(pipeline:inout Mongo.PipelineEncoder)
    {
        for release:Bool in [true, false]
        {
            pipeline[.lookup] = Mongo.LookupDocument.init
            {
                $0[.from] = Unidoc.DB.Editions.name
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

        guard
        case .tags(_, _, user: let user) = self
        else
        {
            return
        }

        do
        {
            //  Compute id of local snapshot, if one were to exist.
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
        do
        {
            //  Lookup other aliases for this package.
            let aliases:Mongo.List<Unidoc.PackageAlias, Mongo.KeyPath> = .init(
                in: Output[.aliases])

            pipeline[.lookup] = .init
            {
                $0[.from] = Unidoc.DB.PackageAliases.name
                $0[.localField] = Self.target / Unidoc.PackageMetadata[.id]
                $0[.foreignField] = Unidoc.PackageAlias[.coordinate]
                $0[.as] = aliases.expression
            }

            pipeline[.set] = .init
            {
                $0[Output[.aliases]] = .expr { $0[.map] = aliases.map { $0[.id] } }
            }
        }
        do
        {
            //  Lookup the associated realm.
            pipeline[.lookup] = .init
            {
                $0[.from] = Unidoc.DB.Realms.name
                $0[.localField] = Self.target / Unidoc.PackageMetadata[.realm]
                $0[.foreignField] = Unidoc.RealmMetadata[.id]
                $0[.as] = Output[.realm]
            }
            //  Unbox single-element array.
            pipeline[.set] = .init
            {
                $0[Output[.realm]] = .expr { $0[.first] = Output[.realm] }
            }
        }
        if  let user:Unidoc.User.ID
        {
            //  Lookup the querying user.
            pipeline[.lookup] = .init
            {
                $0[.from] = Unidoc.DB.Users.name
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
            $0[.from] = Unidoc.DB.Volumes.name
            $0[.localField] = id
            $0[.foreignField] = Unidoc.VolumeMetadata[.id]
            $0[.as] = volume
        }

        //  Check if a symbol graph has been uploaded for this edition.
        pipeline[.lookup] = Mongo.LookupDocument.init
        {
            $0[.from] = Unidoc.DB.Snapshots.name
            $0[.localField] = id
            $0[.foreignField] = Unidoc.Snapshot[.id]
            $0[.pipeline] = .init
            {
                $0[.replaceWith] = .init
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
                    $0[Graph[.link]] = Unidoc.Snapshot[.link]
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
