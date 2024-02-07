import BSON
import MongoDB

extension Mongo
{
    /// A type that expects a single output document from its ``query``.
    public
    typealias SingleOutputEndpoint = _MongoSingleOutputEndpoint
}
/// The name of this protocol is ``Mongo.SingleOutputEndpoint``.
public
protocol _MongoSingleOutputEndpoint<Query>:Mongo.PipelineEndpoint
    where   Query.Iteration.Stride == Never,
            Query.Iteration.Batch == Query.Iteration.BatchElement?
{
    /// An **idempotent** accessor for the singular result of the ``query``.
    ///
    /// The easiest way to implement this property is to declare a mutable stored property
    /// matching this requirement.
    var value:Query.Iteration.BatchElement? { get set }
}

extension Mongo.SingleOutputEndpoint
{
    /// Consumes the documents in the given batch as if they were iterated and
    /// sequentially-assigned to an **idempotent** ``value`` property.
    ///
    /// As an implementation detail, this method just assigns the last document of the array
    /// to the ``value`` property.
    @inlinable public mutating
    func yield(batch:[Query.Iteration.BatchElement]) throws
    {
        self.value = batch.last
    }

    /// A more-efficient, cursorless implementation of
    /// ``Mongo/PipelineEndpoint.pull(from:with:)``.
    @inlinable public mutating
    func pull(from database:Mongo.Database, with session:Mongo.Session) async throws
    {
        self.value = try await session.run(
            command: self.query.command(stride: nil),
            against: database,
            on: Self.replica)
    }
}
