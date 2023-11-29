import BSONDecoding
import MongoDB

@available(*, deprecated, renamed: "Mongo.PipelineQuery")
public
typealias DatabaseQuery<Output> = Mongo.PipelineQuery<Mongo.Collation, Mongo.Single<Output>>
    where Output:BSONDecodable

extension Mongo
{
    public
    typealias PipelineQuery = _MongoPipelineQuery
}

/// The name of this protocol is ``Mongo.PipelineQuery``.
public
protocol _MongoPipelineQuery<Collation, Iteration>:Sendable
{
    associatedtype Collation:Mongo.CollationType
    /// Specifies the iteration mode for the pipeline’s expected output.
    ///
    /// For pipelines that return a single document, use ``Mongo.Single``.
    ///
    /// For pipelines that return multiple documents, yet do not require cursor iteration, use
    /// ``Mongo.SingleBatch``.
    associatedtype Iteration:MongoReadEffect

    //associatedtype Origin:Mongo.CollectionModel

    /// Constructs a pipeline by adding stages to the given encoder.
    func build(pipeline:inout Mongo.PipelineEncoder)

    /// The collection the pipeline draws its input documents from.
    var origin:Mongo.Collection { get }
    /// The key specification for an index to use.
    var hint:Mongo.SortDocument? { get }
}
extension Mongo.PipelineQuery where Iteration.Stride == Int
{
    func command(stride:Int) -> Mongo.Aggregate<Iteration>
    {
        .init(self.origin,
            pipeline: .init(with: self.build(pipeline:)),
            stride: stride)
        {
            $0[.collation] = Collation.spec
            $0[.hint] = self.hint
        }
    }
}
extension Mongo.PipelineQuery where Iteration.Stride == Never?
{
    @inlinable public
    var command:Mongo.Aggregate<Iteration>
    {
        .init(self.origin, pipeline: .init(with: self.build(pipeline:)))
        {
            $0[.collation] = Collation.spec
            $0[.hint] = self.hint
        }
    }
}
