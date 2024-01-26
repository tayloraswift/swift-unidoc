import MongoDB
import MongoQL
import Unidoc
import UnidocDB
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct ActivityQuery:Equatable, Hashable, Sendable
    {
        public
        let limit:Int

        @inlinable public
        init(limit:Int = 16)
        {
            self.limit = limit
        }
    }
}
extension Unidoc.ActivityQuery:Mongo.PipelineQuery
{
    public
    typealias CollectionOrigin = Unidoc.DB.DocsFeed
    public
    typealias Collation = SimpleCollation
    public
    typealias Iteration = Mongo.Single<Output>

    @inlinable public
    var hint:Mongo.CollectionIndex? { nil }

    public
    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        //  Cannot use $natural sort in an aggregation pipeline.
        pipeline[.sort] = .init
        {
            $0[Unidoc.DB.DocsFeed.Activity<Unidoc.Edition>[.id]] = (-)
        }

        pipeline[.limit] = self.limit

        pipeline[.facet] = .init
        {
            $0[Output[.docs]] = .init
            {
                $0[.lookup] = .init
                {
                    let id:Mongo.Variable<Unidoc.Edition> = "id"

                    $0[.from] = Unidoc.DB.Volumes.name
                    $0[.let] = .init
                    {
                        $0[let: id] = Unidoc.DB.DocsFeed.Activity<Unidoc.Edition>[.volume]
                    }
                    $0[.pipeline] = .init
                    {
                        $0[.match] = .init
                        {
                            $0[.expr] = .expr
                            {
                                $0[.eq] = (Unidoc.VolumeMetadata[.id], id)
                            }
                        }

                        $0[.project] = .init(with: Unidoc.VolumeMetadata.names(_:))
                    }
                    $0[.as] = Unidoc.DB.DocsFeed.Activity<Unidoc.VolumeMetadata>[.volume]
                }

                $0[.unwind] = Unidoc.DB.DocsFeed.Activity<Unidoc.VolumeMetadata>[.volume]
            }
        }

        pipeline[.lookup] = .init
        {
            $0[.from] = Unidoc.DB.RepoFeed.name
            $0[.pipeline] = .init
            {
                $0[.sort] = .init
                {
                    $0[Unidoc.DB.RepoFeed.Activity[.id]] = (-)
                }

                $0[.limit] = self.limit
            }
            $0[.as] = Output[.repo]
        }
    }
}
