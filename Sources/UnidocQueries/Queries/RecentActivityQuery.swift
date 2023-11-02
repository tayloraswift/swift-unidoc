import MongoQL
import Unidoc
import UnidocDB
import UnidocRecords

@frozen public
struct RecentActivityQuery:Equatable, Hashable, Sendable
{
    public
    let limit:Int

    @inlinable public
    init(limit:Int = 16)
    {
        self.limit = limit
    }
}
extension RecentActivityQuery:DatabaseQuery
{
    public
    typealias Collation = SimpleCollation

    @inlinable public
    var origin:Mongo.Collection { UnidocDatabase.DocsFeed.name }

    @inlinable public
    var hint:Mongo.SortDocument? { nil }

    public
    func build(pipeline:inout Mongo.Pipeline)
    {
        pipeline.stage
        {
            //  Cannot use $natural sort in an aggregation pipeline.
            $0[.sort] = .init
            {
                $0[UnidocDatabase.DocsFeed.Activity<Unidoc.Zone>[.id]] = (-)
            }
        }
        pipeline.stage
        {
            $0[.limit] = self.limit
        }

        pipeline.stage
        {
            $0[.facet] = .init
            {
                $0[Output[.docs]] = .init
                {
                    $0.stage
                    {
                        $0[.lookup] = .init
                        {
                            let id:Mongo.Variable<Unidoc.Zone> = "id"

                            $0[.from] = UnidocDatabase.Volumes.name
                            $0[.let] = .init
                            {
                                $0[let: id] =
                                    UnidocDatabase.DocsFeed.Activity<Unidoc.Zone>[.volume]
                            }
                            $0[.pipeline] = .init
                            {
                                $0.stage
                                {
                                    $0[.match] = .init
                                    {
                                        $0[.expr] = .expr
                                        {
                                            $0[.eq] = (Volume.Meta[.id], id)
                                        }
                                    }
                                }
                                $0.stage
                                {
                                    $0[.project] = .init(with: Volume.Meta.names(_:))
                                }
                            }
                            $0[.as] = UnidocDatabase.DocsFeed.Activity<Volume.Meta>[.volume]
                        }
                    }
                    $0.stage
                    {
                        $0[.unwind] = UnidocDatabase.DocsFeed.Activity<Volume.Meta>[.volume]
                    }
                }
            }
        }

        pipeline.stage
        {
            $0[.lookup] = .init
            {
                $0[.from] = UnidocDatabase.RepoFeed.name
                $0[.pipeline] = .init
                {
                    $0.stage
                    {
                        $0[.sort] = .init
                        {
                            $0[UnidocDatabase.RepoFeed.Activity[.id]] = (-)
                        }
                    }
                    $0.stage
                    {
                        $0[.limit] = self.limit
                    }
                }
                $0[.as] = Output[.repo]
            }
        }
    }
}
