import ModuleGraphs
import MongoQL
import Unidoc
import UnidocDB
import UnidocLinker

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
    typealias Database = PackageDatabase

    @inlinable public
    var origin:Mongo.Collection { PackageDatabase.Packages.name }

    @inlinable public
    var hint:Mongo.SortDocument?
    {
        .init
        {
            $0[PackageRecord[.id]] = (+)
        }
    }

    public
    func build(pipeline:inout Mongo.Pipeline)
    {
        pipeline.stage
        {
            $0[.match] = .init
            {
                $0[PackageRecord[.id]] = self.package
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
                $0[Output[.record]] = Mongo.Pipeline.ROOT
            }
        }
        for release:Bool in [true, false]
        {
            pipeline.stage
            {
                $0[.lookup] = Mongo.LookupDocument.init
                {
                    let package:Mongo.Variable<Int32> = "package"

                    $0[.from] = PackageDatabase.Editions.name
                    $0[.let] = .init
                    {
                        $0[let: package] = Output[.record] / PackageRecord[.cell]
                    }
                    $0[.pipeline] = .init
                    {
                        $0.stage
                        {
                            $0[.match] = .init
                            {
                                $0[.expr] = .expr
                                {
                                    $0[.eq] = (PackageEdition[.package], package)
                                }
                            }
                        }
                        $0.stage
                        {
                            $0[.match] = .init
                            {
                                $0[PackageEdition[.release]] = release
                                $0[PackageEdition[.release]] = .init
                                {
                                    $0[.exists] = true
                                }
                                $0[PackageEdition[.patch]] = .init
                                {
                                    $0[.exists] = true
                                }
                            }
                        }
                        $0.stage
                        {
                            $0[.sort] = .init
                            {
                                $0[PackageEdition[.patch]] = (-)
                                $0[PackageEdition[.version]] = (-)
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

                        $0.stage
                        {
                            $0[.lookup] = Mongo.LookupDocument.init
                            {
                                let version:Mongo.Variable<Int32> = "version"

                                $0[.from] = PackageDatabase.Graphs.name
                                $0[.let] = .init
                                {
                                    $0[let: version] =
                                        Facet[.edition] / PackageEdition[.version]
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

                        $0.stage
                        {
                            $0[.set] = .init
                            {
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
