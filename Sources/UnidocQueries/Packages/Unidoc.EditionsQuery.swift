import MongoDB
import MongoQL
import SymbolGraphs
import Symbols
import UnidocDB
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct EditionsQuery:Equatable, Hashable, Sendable
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
extension Unidoc.EditionsQuery:Mongo.PipelineQuery
{
    public
    typealias Iteration = Mongo.Single<Output>
}
extension Unidoc.EditionsQuery:Unidoc.AliasingQuery
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
                        $0[Unidoc.EditionOutput[.edition]] = Mongo.Pipeline.ROOT
                    }

                    //  Check if a volume has been created for this edition.
                    $0[.lookup] = .init
                    {
                        $0[.from] = UnidocDatabase.Volumes.name
                        $0[.localField] =
                            Unidoc.EditionOutput[.edition] / Unidoc.EditionMetadata[.id]
                        $0[.foreignField] = Unidoc.VolumeMetadata[.id]
                        $0[.as] = Unidoc.EditionOutput[.volume]
                    }

                    //  Check if a symbol graph has been uploaded for this edition.
                    $0[.lookup] = Mongo.LookupDocument.init
                    {
                        $0[.from] = UnidocDatabase.Snapshots.name
                        $0[.localField] =
                            Unidoc.EditionOutput[.edition] / Unidoc.EditionMetadata[.id]
                        $0[.foreignField] = Unidoc.Snapshot[.id]
                        $0[.pipeline] = .init
                        {
                            $0[.replaceWith] = .init
                            {
                                $0[Unidoc.EditionOutput.Graph[.abi]] =
                                    Unidoc.Snapshot[.metadata] / SymbolGraphMetadata[.abi]

                                $0[Unidoc.EditionOutput.Graph[.bytes]] = .expr
                                {
                                    $0[.objectSize] = Unidoc.Snapshot[.graph]
                                }
                            }
                        }
                        $0[.as] = Unidoc.EditionOutput[.graph]
                    }

                    //  Unbox single-element arrays.
                    $0[.set] = .init
                    {
                        $0[Unidoc.EditionOutput[.volume]] = .expr
                        {
                            $0[.first] = Unidoc.EditionOutput[.volume]
                        }
                        $0[Unidoc.EditionOutput[.graph]] = .expr
                        {
                            $0[.first] = Unidoc.EditionOutput[.graph]
                        }
                    }
                }
                $0[.as] = Output[release ? .releases : .prereleases]
            }
        }
    }
}
