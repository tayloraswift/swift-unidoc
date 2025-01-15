import BSON
import MongoDB
import UnidocDB
import UnixTime

extension Unidoc
{
    @frozen public
    struct PackagesCrawledQuery
    {
        @usableFromInline
        let range:Range<UnixDate>

        @inlinable public
        init(during range:Range<UnixDate>)
        {
            self.range = range
        }
    }
}
extension Unidoc.PackagesCrawledQuery:Mongo.PipelineQuery
{
    public
    typealias CollectionOrigin = Unidoc.DB.CrawlingWindows
    public
    typealias Iteration = Mongo.SingleBatch<Date>

    @inlinable public
    var collation:Mongo.Collation { .simple }
    @inlinable public
    var hint:Mongo.CollectionIndex? { nil }

    public
    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline[stage: .match]
        {
            $0[Unidoc.CrawlingWindow[.id]]
            {
                $0[.gte] = UnixMillisecond.init(self.range.lowerBound)
            }
            $0[Unidoc.CrawlingWindow[.id]]
            {
                $0[.lt] = UnixMillisecond.init(self.range.upperBound)
            }
        }

        pipeline[stage: .replaceWith, using: Date.CodingKey.self]
        {
            $0[.window] = Mongo.Pipeline.ROOT
        }

        let count:Mongo.AnyKeyPath = "_count"

        pipeline[stage: .lookup]
        {
            $0[.from] = Unidoc.DB.Packages.name
            $0[.localField] = Date[.window] / Unidoc.CrawlingWindow[.id]
            $0[.foreignField] = Unidoc.PackageMetadata[.repo] / Unidoc.PackageRepo[.created]
            $0[.pipeline]
            {
                /// This improves query performance enormously, as it gets MongoDB to use the
                /// partial index. But why?? The `localField` is always non-null!
                $0[stage: .match]
                {
                    $0[Unidoc.PackageMetadata[.repo]] { $0[.exists] = true }
                }

                $0[stage: .count] = count
            }
            $0[.as] = Date[.repos]
        }

        //  Unbox the count.
        pipeline[stage: .set, using: Date.CodingKey.self]
        {
            $0[.repos] { $0[.first] = Date[.repos] }
        }
        pipeline[stage: .set, using: Date.CodingKey.self]
        {
            $0[.repos] = Date[.repos] / count
        }
    }
}
