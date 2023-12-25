import BSON
import MongoDB
import UnidocDB
import UnixTime

extension Unidoc
{
    public
    struct PackagesCreatedQuery
    {
        @usableFromInline
        let timeframe:Range<UnixDate>
        @usableFromInline
        let limit:Int

        @inlinable public
        init(during timeframe:Range<UnixDate>, limit:Int)
        {
            self.timeframe = timeframe
            self.limit = limit
        }
    }
}
extension Unidoc.PackagesCreatedQuery:Mongo.PipelineQuery
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
                $0[.gte] = BSON.Millisecond.init(UnixInstant.date(self.timeframe.lowerBound))
            }
            $0[Unidoc.PackageMetadata[.repo] / Unidoc.PackageRepo[.created]] = .init
            {
                $0[.lt] = BSON.Millisecond.init(UnixInstant.date(self.timeframe.upperBound))
            }
        }

        pipeline[.limit] = self.limit

        pipeline[.sort] = .init
        {
            $0[Unidoc.PackageMetadata[.symbol]] = (+)
        }
    }
}
