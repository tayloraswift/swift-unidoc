import MongoQL
import UnidocDB

extension Unidoc {
    /// Something that can filter an input stream of ``PackageMetadata`` documents.
    public protocol PackagePredicate: Equatable, Hashable, Sendable {
        func extend(pipeline: inout Mongo.PipelineEncoder)

        var hint: Mongo.CollectionIndex? { get }
    }
}
