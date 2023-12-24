import BSON
import MongoDB
import UnidocDB
import UnixTime

extension Unidoc
{
    public
    struct PackageReposCreatedQuery
    {
        let timeframe:Range<UnixDay>
        let limit:Int
    }
}
extension Unidoc.PackageReposCreatedQuery:Mongo.PipelineQuery
{
    public
    typealias CollectionOrigin = UnidocDatabase.Packages
    public
    typealias Collation = SimpleCollation
    public
    typealias Iteration = Mongo.SingleBatch<Unidoc.PackageMetadata>

    public
    var hint:Mongo.CollectionIndex? { UnidocDatabase.Packages.indexRepoCreated }

    public
    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline[.match] = .init
        {
            $0[Unidoc.PackageMetadata[.repo]] = .init { $0[.exists] = true }

            $0[Unidoc.PackageMetadata[.repo] / Unidoc.PackageRepo[.created]] = .init
            {
                $0[.gte] = BSON.Millisecond.init(UnixInstant.day(self.timeframe.lowerBound))
            }
            $0[Unidoc.PackageMetadata[.repo] / Unidoc.PackageRepo[.created]] = .init
            {
                $0[.lt] = BSON.Millisecond.init(UnixInstant.day(self.timeframe.upperBound))
            }
        }

        pipeline[.limit] = self.limit

        pipeline[.sort] = .init
        {
            $0[Unidoc.PackageMetadata[.symbol]] = (+)
        }
    }
}
