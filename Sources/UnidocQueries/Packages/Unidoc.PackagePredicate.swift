import MongoQL
import UnidocDB

extension Unidoc
{
    /// Something that can filter an input stream of ``Unidoc.PackageMetadata`` documents.
    public
    typealias PackagePredicate = _UnidocPackagePredicate
}
/// The name of this protocol is ``Mongo.PackagePredicate``.
public
protocol _UnidocPackagePredicate:Equatable, Hashable, Sendable
{
    func extend(pipeline:inout Mongo.PipelineEncoder)

    var hint:Mongo.CollectionIndex? { get }
}
