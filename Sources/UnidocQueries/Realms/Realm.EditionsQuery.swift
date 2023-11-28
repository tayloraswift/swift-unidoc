import MongoDB
import MongoQL
import Symbols
import UnidocDB
import UnidocRecords

extension Realm
{
    @frozen public
    struct EditionsQuery:Equatable, Hashable, Sendable
    {
        public
        let package:Symbol.Package
        public
        let limit:Int

        @inlinable public
        init(package:Symbol.Package, limit:Int)
        {
            self.package = package
            self.limit = limit
        }
    }
}
extension Realm.EditionsQuery:Mongo.PipelineQuery
{
    public
    typealias Iteration = Mongo.Single<Output>
}
extension Realm.EditionsQuery:Realm.PackageQuery
{
    @inlinable public static
    var package:Mongo.KeyPath { Output[.package] }

    public
    func extend(pipeline:inout Mongo.PipelineEncoder)
    {
        guard self.limit > 0
        else
        {
            return
        }

        for release:Bool in [true, false]
        {
            pipeline[.lookup] = Mongo.LookupDocument.init
            {
                let package:Mongo.Variable<Int32> = "package"

                $0[.from] = UnidocDatabase.Editions.name
                $0[.let] = .init
                {
                    $0[let: package] = Output[.package] / Realm.Package[.id]
                }
                $0[.pipeline] = .init
                {
                    $0[.match] = .init
                    {
                        $0[.expr] = .expr
                        {
                            $0[.eq] = (Realm.Edition[.package], package)
                        }
                    }

                    $0[.match] = .init
                    {
                        $0[Realm.Edition[.release]] = release
                        $0[Realm.Edition[.release]] = .init { $0[.exists] = true }
                        $0[Realm.Edition[.patch]] = .init { $0[.exists] = true }
                    }

                    $0[.sort] = .init
                    {
                        $0[Realm.Edition[.patch]] = (-)
                        $0[Realm.Edition[.version]] = (-)
                    }

                    $0[.limit] = self.limit

                    $0[.replaceWith] = .init
                    {
                        $0[Facet[.edition]] = Mongo.Pipeline.ROOT
                    }

                    //  Check if a volume has been created for this edition.
                    $0[.lookup] = .init
                    {
                        $0[.from] = UnidocDatabase.Volumes.name
                        $0[.localField] = Facet[.edition] / Realm.Edition[.id]
                        $0[.foreignField] = Volume.Meta[.id]
                        $0[.as] = Facet[.volume]
                    }

                    //  Count symbol graphs.
                    $0[.lookup] = Mongo.LookupDocument.init
                    {
                        let edition:Mongo.Variable<Unidoc.Edition> = "edition"

                        $0[.from] = UnidocDatabase.Snapshots.name
                        $0[.let] = .init
                        {
                            $0[let: edition] = Facet[.edition] / Realm.Edition[.id]
                        }
                        $0[.pipeline] = .init
                        {
                            $0[.match] = .init
                            {
                                $0[.expr] = .expr
                                {
                                    $0[.eq] = (Realm.Snapshot[.id], edition)
                                }
                            }

                            $0[.count] = Facet.Graphs[.count]

                            $0[.project] = .init
                            {
                                $0[Facet.Graphs[.count]] = true
                            }
                        }
                        $0[.as] = Facet[.graphs]
                    }

                    //  Unbox single-element arrays.
                    $0[.set] = .init
                    {
                        $0[Facet[.volume]] = .expr { $0[.first] = Facet[.volume] }
                        $0[Facet[.graphs]] = .expr { $0[.first] = Facet[.graphs] }
                    }
                }
                $0[.as] = Output[release ? .releases : .prereleases]
            }
        }
    }
}
