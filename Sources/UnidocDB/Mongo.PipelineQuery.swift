import BSONDecoding
import MongoDB

extension Mongo
{
    public
    typealias PipelineQuery = _MongoPipelineQuery
}

/// The name of this protocol is ``Mongo.PipelineQuery``.
public
protocol _MongoPipelineQuery<CollectionOrigin>:Sendable
{
    /// The collection the pipeline draws its input documents from.
    associatedtype CollectionOrigin:Mongo.CollectionModel
    /// Specifies the collation to use for the query. This should match any collation specified
    /// in the index ``hint``, if provided.
    associatedtype Collation:Mongo.CollationType
    /// Specifies the iteration mode for the pipeline’s expected output.
    ///
    /// For pipelines that return a single document, use ``Mongo.Single``.
    ///
    /// For pipelines that return multiple documents, yet do not require cursor iteration, use
    /// ``Mongo.SingleBatch``.
    associatedtype Iteration:MongoReadEffect

    /// Constructs a pipeline by adding stages to the given encoder.
    func build(pipeline:inout Mongo.PipelineEncoder)

    /// The index to use.
    var hint:Mongo.CollectionIndex? { get }
}
extension Mongo.PipelineQuery where Iteration.Stride == Int
{
    func command(stride:Int) -> Mongo.Aggregate<Iteration>
    {
        .init(CollectionOrigin.name,
            pipeline: .init(with: self.build(pipeline:)),
            stride: stride)
        {
            $0[.collation] = Collation.spec
            $0[.hint] = self.hint?.fields
        }
    }
}
extension Mongo.PipelineQuery where Iteration.Stride == Never?
{
    @inlinable public
    var command:Mongo.Aggregate<Iteration>
    {
        .init(CollectionOrigin.name, pipeline: .init(with: self.build(pipeline:)))
        {
            $0[.collation] = Collation.spec
            $0[.hint] = self.hint?.fields
        }
    }
}
