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
    typealias Iteration = Mongo.Single<Output>

    @inlinable public
    var collation:Mongo.Collation { .simple }
    @inlinable public
    var hint:Mongo.CollectionIndex? { nil }

    public
    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        //  Cannot use $natural sort in an aggregation pipeline.
        pipeline[stage: .sort,
            using: Unidoc.DB.DocsFeed.Activity<Unidoc.Edition>.CodingKey.self]
        {
            $0[.id] = (-)
        }

        pipeline[stage: .limit] = self.limit

        pipeline[stage: .facet, using: Output.CodingKey.self]
        {
            $0[.docs]
            {
                $0[stage: .lookup]
                {
                    let id:Mongo.Variable<Unidoc.Edition> = "id"

                    $0[.from] = Unidoc.DB.Volumes.name
                    $0[.let]
                    {
                        $0[let: id] = Unidoc.DB.DocsFeed.Activity<Unidoc.Edition>[.volume]
                    }
                    $0[.pipeline]
                    {
                        $0[stage: .match]
                        {
                            $0[.expr] { $0[.eq] = (Unidoc.VolumeMetadata[.id], id) }
                        }

                        $0[stage: .project] = Unidoc.VolumeMetadata.NameFields.init()
                    }
                    $0[.as] = Unidoc.DB.DocsFeed.Activity<Unidoc.VolumeMetadata>[.volume]
                }

                $0[stage: .unwind] = Unidoc.DB.DocsFeed.Activity<Unidoc.VolumeMetadata>[.volume]
            }
        }

        pipeline[stage: .lookup]
        {
            $0[.from] = Unidoc.DB.RepoFeed.name
            $0[.pipeline]
            {
                $0[stage: .sort, using: Unidoc.DB.RepoFeed.Activity.CodingKey.self]
                {
                    $0[.id] = (-)
                }

                $0[stage: .limit] = self.limit
            }
            $0[.as] = Output[.repo]
        }
    }
}
