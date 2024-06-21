import MongoDB
import MongoQL
import SymbolGraphs
import Symbols
import UnidocAPI
import UnidocDB
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct TagsQuery:Sendable
    {
        public
        let symbol:Symbol.Package
        public
        let filter:VersionSeries
        public
        let limit:Int
        public
        let page:Int
        public
        let user:Account?

        @inlinable public
        init(symbol:Symbol.Package,
            filter:VersionSeries,
            limit:Int,
            page:Int,
            as user:Account? = nil)
        {
            self.symbol = symbol
            self.filter = filter
            self.limit = limit
            self.page = page
            self.user = user
        }
    }
}
extension Unidoc.TagsQuery:Mongo.PipelineQuery
{
    public
    typealias Iteration = Mongo.Single<Output>
}
extension Unidoc.TagsQuery:Unidoc.AliasingQuery
{
    public
    typealias CollectionOrigin = Unidoc.DB.PackageAliases
    public
    typealias CollectionTarget = Unidoc.DB.Packages

    @inlinable public static
    var target:Mongo.AnyKeyPath { Output[.package] }

    public
    func extend(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline.loadTags(matching: .latest(self.filter),
            limit: self.limit,
            skip: self.limit * self.page,
            from: Self.target,
            into: Output[.tags])

        if  let id:Unidoc.Account = self.user
        {
            //  Lookup the querying user.
            pipeline.loadUser(matching: id, as: Output[.user])
        }
    }
}
