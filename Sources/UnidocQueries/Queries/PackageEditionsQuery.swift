import ModuleGraphs
import MongoQL
import Unidoc
import UnidocDB
import UnidocLinker
import UnidocRecords

@frozen public
struct PackageEditionsQuery:Equatable, Hashable, Sendable
{
    public
    let package:PackageIdentifier
    public
    let limit:Int

    @inlinable public
    init(package:PackageIdentifier, limit:Int = 12)
    {
        self.package = package
        self.limit = limit
    }
}
extension PackageEditionsQuery:DatabaseQuery
{
    public
    typealias Collation = SimpleCollation

    @inlinable public
    var origin:Mongo.Collection { UnidocDatabase.Packages.name }

    @inlinable public
    var hint:Mongo.SortDocument?
    {
        .init
        {
            $0[Realm.Package[.id]] = (+)
        }
    }

    public
    func build(pipeline:inout Mongo.Pipeline)
    {
        pipeline.stage
        {
            $0[.match] = .init
            {
                $0[Realm.Package[.id]] = self.package
            }
        }
        pipeline.stage
        {
            $0[.limit] = 1
        }
        pipeline.stage
        {
            $0[.replaceWith] = .init
            {
                $0[Output[.package]] = Mongo.Pipeline.ROOT
            }
        }
        for release:Bool in [true, false]
        {
            pipeline.stage
            {
                $0[.lookup] = Mongo.LookupDocument.init
                {
                    let package:Mongo.Variable<Int32> = "package"

                    $0[.from] = UnidocDatabase.Editions.name
                    $0[.let] = .init
                    {
                        $0[let: package] = Output[.package] / Realm.Package[.coordinate]
                    }
                    $0[.pipeline] = .init
                    {
                        $0.stage
                        {
                            $0[.match] = .init
                            {
                                $0[.expr] = .expr
                                {
                                    $0[.eq] = (Realm.Edition[.package], package)
                                }
                            }
                        }
                        $0.stage
                        {
                            $0[.match] = .init
                            {
                                $0[Realm.Edition[.release]] = release
                                $0[Realm.Edition[.release]] = .init
                                {
                                    $0[.exists] = true
                                }
                                $0[Realm.Edition[.patch]] = .init
                                {
                                    $0[.exists] = true
                                }
                            }
                        }
                        $0.stage
                        {
                            $0[.sort] = .init
                            {
                                $0[Realm.Edition[.patch]] = (-)
                                $0[Realm.Edition[.version]] = (-)
                            }
                        }
                        $0.stage
                        {
                            $0[.limit] = self.limit
                        }
                        $0.stage
                        {
                            $0[.replaceWith] = .init
                            {
                                $0[Facet[.edition]] = Mongo.Pipeline.ROOT
                            }
                        }

                        //  Check if a volume has been created for this edition.
                        $0.stage
                        {
                            $0[.lookup] = .init
                            {
                                $0[.from] = UnidocDatabase.Volumes.name
                                $0[.localField] = Facet[.edition] / Realm.Edition[.id]
                                $0[.foreignField] = Volume.Meta[.id]
                                $0[.as] = Facet[.volume]
                            }
                        }

                        //  Count symbol graphs.
                        $0.stage
                        {
                            $0[.lookup] = Mongo.LookupDocument.init
                            {
                                let version:Mongo.Variable<Int32> = "version"

                                $0[.from] = UnidocDatabase.Graphs.name
                                $0[.let] = .init
                                {
                                    $0[let: version] =
                                        Facet[.edition] / Realm.Edition[.version]
                                }
                                $0[.pipeline] = .init
                                {
                                    $0.stage
                                    {
                                        $0[.match] = .init
                                        {
                                            $0[.expr] = .expr
                                            {
                                                $0[.eq] = (Snapshot[.package], package)
                                            }
                                            $0[.expr] = .expr
                                            {
                                                $0[.eq] = (Snapshot[.version], version)
                                            }
                                        }
                                    }
                                    $0.stage
                                    {
                                        $0[.count] = Facet.Graphs[.count]
                                    }
                                    $0.stage
                                    {
                                        $0[.project] = .init
                                        {
                                            $0[Facet.Graphs[.count]] = true
                                        }
                                    }
                                }
                                $0[.as] = Facet[.graphs]
                            }
                        }

                        //  Unbox single-element arrays.
                        $0.stage
                        {
                            $0[.set] = .init
                            {
                                $0[Facet[.volume]] = .expr { $0[.first] = Facet[.volume] }
                                $0[Facet[.graphs]] = .expr { $0[.first] = Facet[.graphs] }
                            }
                        }
                    }
                    $0[.as] = Output[release ? .releases : .prereleases]
                }
            }
        }
    }
}
