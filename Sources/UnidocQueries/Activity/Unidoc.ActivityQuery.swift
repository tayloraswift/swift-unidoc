import BSON
import MongoDB
import MongoQL
import Symbols
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
extension Unidoc.ActivityQuery
{
    private
    static var featured:[Featured<Unidoc.Stem>]
    {
        [
        ]
    }
}
extension Unidoc.ActivityQuery:Mongo.PipelineQuery
{
    public
    typealias Iteration = Mongo.Single<Output>

    /// This must be ``Mongo.Collation/casefolding`` for the featured article lookup to use
    /// the index.
    @inlinable public
    var collation:Mongo.Collation { .casefolding }
    @inlinable public
    var from:Mongo.Collection? { nil }
    @inlinable public
    var hint:Mongo.CollectionIndex? { nil }

    public
    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline[stage: .documents] = [[:] as [BSON.Key: Never]]
        pipeline[stage: .lookup]
        {
            $0[.pipeline]
            {
                $0[stage: .documents] = Self.featured
                $0[stage: .lookup]
                {
                    let trunk:Mongo.Variable<Symbol.Package> = "trunk"
                    let stem:Mongo.Variable<Unidoc.Stem> = "stem"

                    $0[.from] = Unidoc.DB.Vertices.name
                    $0[.let]
                    {
                        $0[let: trunk] = Featured<Unidoc.Stem>[.package]
                        $0[let: stem] = Featured<Unidoc.Stem>[.article]
                    }
                    $0[.pipeline]
                    {
                        $0[stage: .match]
                        {
                            $0[.and]
                            {
                                $0 { $0[Unidoc.AnyVertex[.linkable]] = true }
                                $0 { $0[.expr] { $0[.eq] = (Unidoc.AnyVertex[.stem], stem) } }
                                $0 { $0[.expr] { $0[.eq] = (Unidoc.AnyVertex[.trunk], trunk) } }
                            }
                        }
                    }
                    $0[.as] = Featured<Unidoc.AnyVertex>[.article]
                }
                $0[stage: .unwind] = Featured<Unidoc.AnyVertex>[.article]
            }
            $0[.as] = Output[.featured]
        }

        pipeline[stage: .lookup]
        {
            $0[.from] = Unidoc.DB.DocsFeed.name
            $0[.pipeline]
            {
                //  Cannot use $natural sort in an aggregation pipeline.
                $0[stage: .sort,
                    using: Unidoc.DB.DocsFeed.Activity<Unidoc.Edition>.CodingKey.self]
                {
                    $0[.id] = (-)
                }
                $0[stage: .limit] = self.limit
                $0[stage: .lookup]
                {
                    $0[.from] = Unidoc.DB.Volumes.name
                    $0[.localField] = Unidoc.DB.DocsFeed.Activity<Unidoc.Edition>[.volume]
                    $0[.foreignField] = Unidoc.VolumeMetadata[.id]
                    $0[.as] = Unidoc.DB.DocsFeed.Activity<Unidoc.VolumeMetadata>[.volume]
                }

                $0[stage: .unwind] = Unidoc.DB.DocsFeed.Activity<Unidoc.VolumeMetadata>[.volume]
            }
            $0[.as] = Output[.docs]
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
