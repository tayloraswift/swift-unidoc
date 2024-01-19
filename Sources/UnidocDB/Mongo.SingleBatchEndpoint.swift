import BSON
import MongoDB

extension Mongo
{
    /// A type that expects a single batch of output documents from its ``query``.
    public
    typealias SingleBatchEndpoint = _MongoSingleBatchEndpoint
}

public
protocol _MongoSingleBatchEndpoint<Query>:Mongo.PipelineEndpoint
    where   Query.Iteration.Stride == Never,
            Query.Iteration.Batch == [Query.Iteration.BatchElement]
{
    /// An **idempotent** accessor for a single batch of ``query`` outputs.
    ///
    /// The easiest way to implement this property is to declare a mutable stored property
    /// matching this requirement.
    var batch:[Query.Iteration.BatchElement] { get set }
}

extension Mongo.SingleBatchEndpoint
{
    /// Assigns the given documents transparently to the ``batch`` property.
    @inlinable public mutating
    func yield(batch:[Query.Iteration.BatchElement]) throws
    {
        self.batch = batch
    }

    /// A more-efficient, cursorless implementation of
    /// ``Mongo/PipelineEndpoint.pull(from:with:)``.
    @inlinable public mutating
    func pull(from database:Mongo.Database, with session:Mongo.Session) async throws
    {
        self.batch = try await session.run(
            command: self.query.command(stride: nil),
            against: database,
            on: Self.replica)
    }
}
