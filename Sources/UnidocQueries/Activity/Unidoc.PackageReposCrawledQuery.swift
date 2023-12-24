import BSON
import MongoDB
import UnidocDB
import UnixTime

extension Unidoc
{
    public
    struct PackageReposCrawledQuery
    {
        let timeframe:Range<UnixDay>
    }
}
extension Unidoc.PackageReposCrawledQuery:Mongo.PipelineQuery
{
    public
    typealias CollectionOrigin = UnidocDatabase.CrawlingWindows
    public
    typealias Collation = SimpleCollation
    public
    typealias Iteration = Mongo.SingleBatch<Date>

    public
    var hint:Mongo.CollectionIndex? { nil }

    public
    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline[.match] = .init
        {
            $0[Unidoc.CrawlingWindow[.id]] = .init
            {
                $0[.gte] = BSON.Millisecond.init(UnixInstant.day(self.timeframe.lowerBound))
            }
            $0[Unidoc.CrawlingWindow[.id]] = .init
            {
                $0[.lt] = BSON.Millisecond.init(UnixInstant.day(self.timeframe.upperBound))
            }
        }

        pipeline[.replaceWith] = .init
        {
            $0[Date[.window]] = Mongo.Pipeline.ROOT
        }

        let count:Mongo.KeyPath = "_count"

        pipeline[.lookup] = .init
        {
            $0[.from] = UnidocDatabase.Packages.name
            $0[.localField] = Date[.window] / Unidoc.CrawlingWindow[.id]
            $0[.foreignField] = Unidoc.PackageMetadata[.repo] / Unidoc.PackageRepo[.created]
            $0[.pipeline] = .init
            {
                $0[.count] = count
            }
            $0[.as] = Date[.repos]
        }

        //  Unbox the count.
        pipeline[.set] = .init
        {
            $0[Date[.repos]] = .expr { $0[.first] = Date[.repos] }
        }
        pipeline[.set] = .init
        {
            $0[Date[.repos]] = Date[.repos] / count
        }
    }
}
