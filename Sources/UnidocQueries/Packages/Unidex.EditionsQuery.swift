import MongoDB
import MongoQL
import SymbolGraphs
import Symbols
import UnidocDB
import UnidocRecords

extension Unidex
{
    @frozen public
    struct EditionsQuery:Equatable, Hashable, Sendable
    {
        public
        let symbol:Symbol.Package

        @usableFromInline
        let limit:Int
        @usableFromInline
        let user:Unidex.User.ID?

        @inlinable public
        init(package symbol:Symbol.Package, limit:Int, user:Unidex.User.ID? = nil)
        {
            self.symbol = symbol
            self.limit = limit
            self.user = user
        }
    }
}
extension Unidex.EditionsQuery:Mongo.PipelineQuery
{
    public
    typealias Iteration = Mongo.Single<Output>
}
extension Unidex.EditionsQuery:Unidex.AliasingQuery
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
        if  let user:Unidex.User.ID = self.user
        {
            pipeline[.lookup] = .init
            {
                $0[.from] = UnidocDatabase.Users.name
                $0[.pipeline] = .init
                {
                    $0[.match] = .init
                    {
                        $0[Unidex.User[.id]] = user
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
            $0[.localField] = Self.target / Unidex.Package[.realm]
            $0[.foreignField] = Unidex.Realm[.id]
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
                $0[.localField] = Self.target / Unidex.Package[.id]
                $0[.foreignField] = Unidex.Edition[.package]
                $0[.pipeline] = .init
                {
                    $0[.match] = .init
                    {
                        $0[Unidex.Edition[.release]] = release
                        $0[Unidex.Edition[.release]] = .init { $0[.exists] = true }
                    }

                    $0[.sort] = .init
                    {
                        $0[Unidex.Edition[.patch]] = (-)
                        $0[Unidex.Edition[.version]] = (-)
                    }

                    $0[.limit] = self.limit

                    $0[.replaceWith] = .init
                    {
                        $0[Unidex.EditionOutput[.edition]] = Mongo.Pipeline.ROOT
                    }

                    //  Check if a volume has been created for this edition.
                    $0[.lookup] = .init
                    {
                        $0[.from] = UnidocDatabase.Volumes.name
                        $0[.localField] = Unidex.EditionOutput[.edition] / Unidex.Edition[.id]
                        $0[.foreignField] = Volume.Metadata[.id]
                        $0[.as] = Unidex.EditionOutput[.volume]
                    }

                    //  Check if a symbol graph has been uploaded for this edition.
                    $0[.lookup] = Mongo.LookupDocument.init
                    {
                        $0[.from] = UnidocDatabase.Snapshots.name
                        $0[.localField] = Unidex.EditionOutput[.edition] / Unidex.Edition[.id]
                        $0[.foreignField] = Unidex.Snapshot[.id]
                        $0[.pipeline] = .init
                        {
                            $0[.replaceWith] = .init
                            {
                                $0[Unidex.EditionOutput.Graph[.abi]] =
                                    Unidex.Snapshot[.metadata] / SymbolGraphMetadata[.abi]

                                $0[Unidex.EditionOutput.Graph[.bytes]] = .expr
                                {
                                    $0[.objectSize] = Unidex.Snapshot[.graph]
                                }
                            }
                        }
                        $0[.as] = Unidex.EditionOutput[.graph]
                    }

                    //  Unbox single-element arrays.
                    $0[.set] = .init
                    {
                        $0[Unidex.EditionOutput[.volume]] = .expr
                        {
                            $0[.first] = Unidex.EditionOutput[.volume]
                        }
                        $0[Unidex.EditionOutput[.graph]] = .expr
                        {
                            $0[.first] = Unidex.EditionOutput[.graph]
                        }
                    }
                }
                $0[.as] = Output[release ? .releases : .prereleases]
            }
        }
    }
}
