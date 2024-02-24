import BSON
import MongoDB
import UnidocDB
import UnixTime

extension Unidoc
{
    @frozen public
    struct PackagesQuery<Predicate> where Predicate:Unidoc.PackagePredicate
    {
        @usableFromInline
        let package:Predicate

        @inlinable internal
        init(package:Predicate)
        {
            self.package = package
        }
    }
}
extension Unidoc.PackagesQuery<Unidoc.PackageCreated>
{
    @inlinable public
    init(during timeframe:Range<UnixDate>, limit:Int)
    {
        self.init(package: .init(during: timeframe, limit: limit))
    }
}
extension Unidoc.PackagesQuery:Mongo.PipelineQuery
{
    public
    typealias CollectionOrigin = Unidoc.DB.Packages
    public
    typealias Collation = SimpleCollation
    public
    typealias Iteration = Mongo.SingleBatch<Unidoc.PackageOutput>

    @inlinable public
    var hint:Mongo.CollectionIndex? { self.package.hint }

    public
    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        self.package.extend(pipeline: &pipeline)

        Unidoc.PackageOutput.extend(pipeline: &pipeline, from: Mongo.Pipeline.ROOT)
    }
}
