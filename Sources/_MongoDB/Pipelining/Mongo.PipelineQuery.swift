import BSON
import MongoDB

extension Mongo
{
    public
    protocol PipelineQuery<CollectionOrigin>:Sendable
    {
        /// The collection the pipeline draws its input documents from.
        associatedtype CollectionOrigin:CollectionModel
        /// Specifies the iteration mode for the pipeline’s expected output.
        ///
        /// For pipelines that return a single document, use ``Single``.
        ///
        /// For pipelines that return multiple documents, yet do not require cursor iteration,
        /// use ``SingleBatch``.
        associatedtype Iteration:ReadEffect

        /// Constructs a pipeline by adding stages to the given encoder.
        func build(pipeline:inout PipelineEncoder)

        /// Specifies the collation to use for the query. This should match any collation
        /// specified in the index ``hint``, if provided.
        var collation:Collation { get }
        /// The index to use.
        var hint:CollectionIndex? { get }
    }
}
extension Mongo.PipelineQuery
{
    public
    typealias Output = Iteration.BatchElement
}
extension Mongo.PipelineQuery
{
    /// TODO: this should not be public.
    @inlinable package
    func command(stride:Iteration.Stride?) -> Mongo.Aggregate<Iteration>
    {
        .init(CollectionOrigin.name,
            stride: stride,
            pipeline: self.build(pipeline:))
        {
            $0[.collation] = self.collation
            $0[.hint] = self.hint?.id
        }
    }
}
