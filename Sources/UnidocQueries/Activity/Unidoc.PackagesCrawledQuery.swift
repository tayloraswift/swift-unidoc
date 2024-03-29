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
    typealias Collation = SimpleCollation
    public
    typealias Iteration = Mongo.SingleBatch<Date>

    public
    var hint:Mongo.CollectionIndex? { nil }

    public
    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline[stage: .match] = .init
        {
            $0[Unidoc.CrawlingWindow[.id]]
            {
                $0[.gte] = BSON.Millisecond.init(UnixInstant.date(self.range.lowerBound))
            }
            $0[Unidoc.CrawlingWindow[.id]]
            {
                $0[.lt] = BSON.Millisecond.init(UnixInstant.date(self.range.upperBound))
            }
        }

        pipeline[stage: .replaceWith] = .init
        {
            $0[Date[.window]] = Mongo.Pipeline.ROOT
        }

        let count:Mongo.AnyKeyPath = "_count"

        pipeline[stage: .lookup] = .init
        {
            $0[.from] = Unidoc.DB.Packages.name
            $0[.localField] = Date[.window] / Unidoc.CrawlingWindow[.id]
            $0[.foreignField] = Unidoc.PackageMetadata[.repo] / Unidoc.PackageRepo[.created]
            $0[.pipeline] = .init
            {
                /// This improves query performance enormously, as it gets MongoDB to use the
                /// partial index. But why?? The `localField` is always non-null!
                $0[stage: .match] = .init
                {
                    $0[Unidoc.PackageMetadata[.repo]] { $0[.exists] = true }
                }

                $0[stage: .count] = count
            }
            $0[.as] = Date[.repos]
        }

        //  Unbox the count.
        pipeline[stage: .set] = .init
        {
            $0[Date[.repos]] = .expr { $0[.first] = Date[.repos] }
        }
        pipeline[stage: .set] = .init
        {
            $0[Date[.repos]] = Date[.repos] / count
        }
    }
}
