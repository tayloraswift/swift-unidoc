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
    protocol PipelineEndpoint<Query>
    {
        associatedtype Query:PipelineQuery

        /// The replica on which to execute the ``query``.
        ///
        /// For pipelines that write to the database (e.g., pipelines containing an
        /// ``Pipeline.Out/out`` or  ``Pipeline.Out/merge`` stage), this should be
        /// ``ReadPreference/primary``.
        ///
        /// Most read-only pipelines made available to end users should use
        /// ``ReadPreference.nearest`` or ``ReadPreference.secondaryPreferred``, as this allows
        /// the public-facing service to remain functional even if the primary has crashed. This
        /// also frees you to take the primary offline for maintenance or run memory-intensive
        /// operations that have a high risk of crashing it.
        static
        var replica:ReadPreference { get }

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
        func pull(from database:Database, with session:Session) async throws
    }
}
extension Mongo.PipelineEndpoint where Query.Iteration.Stride == Never
{
    @inlinable public
    var stride:Never { [][0] }
}
extension Mongo.PipelineEndpoint
    where   Query.Iteration.Tailing == Mongo.Tailing,
            Query.Iteration.Stride == Int,
            Query.Iteration.Batch == Mongo.CursorBatch<Query.Iteration.BatchElement>
{
    @inlinable public mutating
    func pull(from database:Mongo.Database, with session:Mongo.Session) async throws
    {
        try await session.run(
            command: self.query.command(stride: self.stride),
            against: database,
            on: Self.replica)
        {
            for try await batch:[Query.Iteration.BatchElement] in $0
            {
                try self.yield(batch: batch)
            }
        }
    }
}
extension Mongo.PipelineEndpoint
{
    /// A shorthand for calling ``pull(from:with:)`` with the ``DatabaseModel/id`` and
    /// ``DatabaseModel/session`` of the given `database`.
    @inlinable public mutating
    func pull(from database:some Mongo.DatabaseModel) async throws
    {
        try await self.pull(from: database.id, with: database.session)
    }
}
