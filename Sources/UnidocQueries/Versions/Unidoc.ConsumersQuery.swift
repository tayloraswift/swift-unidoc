import MongoDB
import SymbolGraphs
import Symbols
import UnidocRecords
import UnidocDB

extension Unidoc
{
    @frozen public
    struct ConsumersQuery:Equatable, Sendable
    {
        public
        let symbol:Symbol.Package
        public
        let limit:Int
        public
        let page:Int

        /// We don’t use this yet, but it’s here for future expansion.
        public
        let user:Account?

        @inlinable public
        init(symbol:Symbol.Package, limit:Int, page:Int, as user:Account? = nil)
        {
            self.symbol = symbol
            self.limit = limit
            self.page = page
            self.user = user
        }
    }
}
extension Unidoc.ConsumersQuery:Mongo.PipelineQuery
{
    public
    typealias Iteration = Mongo.Single<Output>
}
extension Unidoc.ConsumersQuery:Unidoc.AliasingQuery
{
    public
    typealias CollectionOrigin = Unidoc.DB.PackageAliases
    public
    typealias CollectionTarget = Unidoc.DB.Packages

    @inlinable public static
    var target:Mongo.AnyKeyPath { Output[.dependency] }

    public
    func extend(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline.loadDependents(limit: self.limit,
            skip: self.limit * self.page,
            from: Self.target,
            into: Output[.dependents])

        if  let id:Unidoc.Account = self.user
        {
            pipeline.loadUser(matching: id, as: Output[.user])
        }
    }
}
