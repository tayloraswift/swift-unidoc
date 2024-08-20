import BSON
import MongoDB
import MongoQL
import UnixTime

extension Mongo
{
    /// A database model is a type that hosts application-specific logic that depends on a
    /// MongoDB database.
    ///
    /// From the perspective of swift code, a ``Mongo.Database`` is just a string name
    /// identifying a database. Therefore, it is often helpful to wrap a ``Mongo.Database``
    /// in an application-specific type to avoid cluttering ``Mongo.Database`` with extensions.
    public
    protocol DatabaseModel:Identifiable<Database>
    {
        var session:Session { get }
        var id:Database { get }

        func setup() async throws
    }
}
extension Mongo.DatabaseModel
{
    /// Drops and reinitializes the database. This destroys *all* its data!
    public
    func drop() async throws
    {
        try await self.session.run(command: Mongo.DropDatabase.init(), against: self.id)
        try await self.setup()
    }
}
extension Mongo.DatabaseModel
{
    @inlinable public
    func query<Query>(with query:Query) async throws -> Query.Iteration.Batch
        where Query:Mongo.PipelineQuery, Query.Iteration.Stride == Never
    {
        try await self.session.run(command: query.command(stride: nil), against: self.id)
    }

    @discardableResult
    @inlinable public
    func update<Update>(
        with update:Update) async throws -> Mongo.UpdateResponse<Update.Target.Element.ID>
        where Update:Mongo.UpdateQuery, Update.Effect.ExecutionPolicy:Mongo.ExecutionPolicy
    {
        try await self.session.run(command: update.command, against: self.id)
    }
}
extension Mongo.DatabaseModel
{
    @inlinable public
    func observe<Source, Delta>(collection:Source,
        every interval:Milliseconds = .milliseconds(30_000),
        since start:inout BSON.Timestamp?,
        yield:(Mongo.ChangeEvent<Delta>) async throws -> ()) async throws where
        Source:Mongo.CollectionModel<Delta.Model>,
        Delta:Mongo.MasterCodingDelta,
        Delta:Sendable,
        Delta.Model.CodingKey:Sendable,
        Delta.Model:BSONDecodable
    {
        try await self.session.run(
            command: Mongo.Aggregate<Mongo.Cursor<Mongo.ChangeEvent<Delta>>>.init(Source.name,
                tailing: .init(timeout: interval, awaits: true))
            {
                $0[stage: .changeStream] { $0[.startAtOperationTime] = start }
            },
            against: collection.database)
        {
            for try await events:[Mongo.ChangeEvent<Delta>] in $0
            {
                for event:Mongo.ChangeEvent<Delta> in events
                {
                    try await yield(event)
                    start = event.clusterTime
                }
            }
        }
    }
}
extension Mongo.DatabaseModel
{
    //  This should be part of the swift-mongodb package. An incredibly interesting statement,
    //  considering this method is private.
    @inlinable
    func explain<Command>(command:Command) async throws -> String
        where Command:Mongo.Command
    {
        try await self.session.run(
            command: Mongo.Explain<Command>.init(verbosity: .executionStats, command: command),
            against: self.id)
    }

    @inlinable public
    func explain(query:some Mongo.PipelineQuery) async throws -> String
    {
        try await self.explain(command: query.command(stride: nil))
    }

    @inlinable public
    func explain(update:some Mongo.UpdateQuery) async throws -> String
    {
        try await self.explain(command: update.command)
    }
}
