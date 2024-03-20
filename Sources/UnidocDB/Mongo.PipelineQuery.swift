import BSON
import MongoDB

extension Mongo
{
    public
    protocol PipelineQuery<CollectionOrigin>:Sendable
    {
        /// The collection the pipeline draws its input documents from.
        associatedtype CollectionOrigin:CollectionModel
        /// Specifies the collation to use for the query. This should match any collation
        /// specified in the index ``hint``, if provided.
        associatedtype Collation:CollationType
        /// Specifies the iteration mode for the pipeline’s expected output.
        ///
        /// For pipelines that return a single document, use ``Single``.
        ///
        /// For pipelines that return multiple documents, yet do not require cursor iteration,
        /// use ``SingleBatch``.
        associatedtype Iteration:ReadEffect

        /// Constructs a pipeline by adding stages to the given encoder.
        func build(pipeline:inout PipelineEncoder)

        /// The index to use.
        var hint:CollectionIndex? { get }
    }
}
extension Mongo.PipelineQuery
{
    @inlinable internal
    func command(stride:Iteration.Stride?) -> Mongo.Aggregate<Iteration>
    {
        .init(CollectionOrigin.name,
            pipeline: .init(with: self.build(pipeline:)),
            stride: stride)
        {
            $0[.collation] = Collation.spec
            $0[.hint] = self.hint?.id
        }
    }
}
