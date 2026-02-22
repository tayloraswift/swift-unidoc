import MongoQL
import SymbolGraphs
import Symbols
import UnidocDB
import UnidocRecords

extension Unidoc {
    @frozen public struct PackagePageQuery<PageSegment>: Equatable, Sendable
        where PageSegment: PackagePageSegment {
        public let symbol: Symbol.Package
        public let limit: Int
        public let page: Int

        /// We don’t use this yet, but it’s here for future expansion.
        public let user: Account?

        @inlinable public init(
            symbol: Symbol.Package,
            limit: Int,
            page: Int,
            as user: Account? = nil
        ) {
            self.symbol = symbol
            self.limit = limit
            self.page = page
            self.user = user
        }
    }
}
extension Unidoc.PackagePageQuery {
    public typealias Output = Unidoc.PackagePageOutput<PageSegment.Item>
}
extension Unidoc.PackagePageQuery: Unidoc.AliasingQuery {
    public typealias Iteration = Mongo.Single<Output>
    public typealias CollectionOrigin = Unidoc.DB.PackageAliases
    public typealias CollectionTarget = Unidoc.DB.Packages

    @inlinable public static var target: Mongo.AnyKeyPath { Output[.package] }

    public func extend(pipeline: inout Mongo.PipelineEncoder) {
        PageSegment.bridge(
            pipeline: &pipeline,
            limit: self.limit,
            skip: self.limit * self.page,
            from: Self.target,
            into: Output[.list]
        )

        if  let id: Unidoc.Account = self.user {
            pipeline.loadUser(matching: id, as: Output[.user])
        }
    }
}
