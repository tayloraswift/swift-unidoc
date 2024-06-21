import MongoDB
import SymbolGraphs
import Symbols
import UnidocRecords
import UnidocDB

extension Unidoc
{
    @frozen public
    struct PackageDependenciesQuery:Equatable, Sendable
    {
        public
        let symbol:Symbol.Package
        public
        let limit:Int
        public
        let page:Int
    }
}
extension Unidoc.PackageDependenciesQuery:Mongo.PipelineQuery
{
    public
    typealias Iteration = Mongo.Single<Output>
}
extension Unidoc.PackageDependenciesQuery:Unidoc.AliasingQuery
{
    public
    typealias CollectionOrigin = Unidoc.DB.PackageAliases
    public
    typealias CollectionTarget = Unidoc.DB.Packages

    @inlinable public static
    var target:Mongo.AnyKeyPath { Unidoc.EditionState[.package] }

    public
    func extend(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline.loadDependents(limit: self.limit,
            skip: self.limit * self.page,
            from: Self.target,
            into: Output[.dependents])
    }
}
