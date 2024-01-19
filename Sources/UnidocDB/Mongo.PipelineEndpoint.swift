import BSON
import MongoDB

extension Mongo
{
    /// A pipeline endpoint is a basic destination type for the results of a
    /// ``Mongo.PipelineQuery``. It attempts to abstract over the plurality of results such a
    /// query could return.
    ///
    /// Most users who don’t expect to iterate cursors will want to implement the
    /// ``Mongo.SingleOutputEndpoint`` or more rarely, the ``Mongo.SingleBatchEndpoint``
    /// derived protocol instead.
    public
    typealias PipelineEndpoint = _MongoPipelineEndpoint
}
/// The name of this protocol is ``Mongo.PipelineEndpoint``.
public
protocol _MongoPipelineEndpoint<Query>
{
    associatedtype Query:Mongo.PipelineQuery

    /// The cursor iteration stride to use when executing the ``query``. Only types that iterate
    /// cursors need to implement this.
    var stride:Query.Iteration.Stride { get }
    /// The query to execute.
    var query:Query { get }

    /// Consumes a batch of output documents from the ``query``. Only types that iterate cursors
    /// need to implement this.
    mutating
    func yield(batch:[Query.Iteration.BatchElement]) throws

    /// Executes the ``query`` against the given `database` with the given `session`.
    ///
    /// Some types of queries can implement this method more efficiently than a generic
    /// cursor-based implementation can. Therefore, it has a witness in the conforming type.
    mutating
    func pull(from database:Mongo.Database,
        with session:Mongo.Session,
        on replica:Mongo.ReadPreference) async throws
}

extension Mongo.PipelineEndpoint
    where Query.Iteration.Stride == Never
{
    @inlinable public
    var stride:Never { [][0] }
}

extension Mongo.PipelineEndpoint
    where   Query.Iteration.Stride == Int,
            Query.Iteration.Batch == Mongo.CursorBatch<Query.Iteration.BatchElement>
{
    @inlinable public mutating
    func pull(from database:Mongo.Database,
        with session:Mongo.Session,
        on replica:Mongo.ReadPreference = .primary) async throws
    {
        try await session.run(
            command: self.query.command(stride: self.stride),
            against: database,
            on: replica)
        {
            for try await batch:[Query.Iteration.BatchElement] in $0
            {
                try self.yield(batch: batch)
            }
        }
    }
}
