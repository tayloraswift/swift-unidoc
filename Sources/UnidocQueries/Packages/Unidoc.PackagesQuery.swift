import BSON
import MongoDB
import UnidocDB
import UnixTime

extension Unidoc {
    @frozen public struct PackagesQuery<Predicate> where Predicate: Unidoc.PackagePredicate {
        @usableFromInline let package: Predicate

        @inlinable internal init(package: Predicate) {
            self.package = package
        }
    }
}
extension Unidoc.PackagesQuery<Unidoc.PackageCreated> {
    @inlinable public init(during timeframe: Range<UnixDate>, limit: Int) {
        self.init(package: .init(during: timeframe, limit: limit))
    }
}
extension Unidoc.PackagesQuery: Mongo.PipelineQuery {
    public typealias Iteration = Mongo.SingleBatch<Unidoc.EditionOutput>

    @inlinable public var collation: Mongo.Collation { .simple }
    @inlinable public var from: Mongo.Collection? { Unidoc.DB.Packages.name }
    @inlinable public var hint: Mongo.CollectionIndex? { self.package.hint }

    public func build(pipeline: inout Mongo.PipelineEncoder) {
        self.package.extend(pipeline: &pipeline)

        pipeline[stage: .replaceWith, using: Unidoc.EditionOutput.CodingKey.self] {
            $0[.package] = Mongo.Pipeline.ROOT
        }

        pipeline.loadEdition(
            matching: .latest(.release),
            from: Unidoc.EditionOutput[.package],
            into: Unidoc.EditionOutput[.edition]
        )
    }
}
