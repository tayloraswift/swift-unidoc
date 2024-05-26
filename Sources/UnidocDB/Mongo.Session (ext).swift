import BSON
import Durations
import MongoDB

extension Mongo.Session
{
    @inlinable public
    func query<Query>(database:Mongo.Database,
        with query:Query) async throws -> Query.Iteration.Batch
        where Query:Mongo.PipelineQuery, Query.Iteration.Stride == Never
    {
        try await self.run(command: query.command(stride: nil), against: database)
    }

    @discardableResult
    @inlinable public
    func update<Update>(database:Mongo.Database,
        with update:Update) async throws -> Mongo.UpdateResponse<Update.Target.Element.ID>
        where Update:Mongo.UpdateQuery, Update.Effect.ExecutionPolicy:Mongo.ExecutionPolicy
    {
        try await self.run(command: update.command, against: database)
    }
}
extension Mongo.Session
{
    @inlinable public
    func observe<Source, Delta>(collection:Source,
        every interval:Milliseconds = 30_000,
        since start:inout BSON.Timestamp?,
        yield:(Mongo.ChangeEvent<Delta>) async throws -> ()) async throws where
        Source:Mongo.CollectionModel<Delta.Model>,
        Delta:Mongo.MasterCodingDelta,
        Delta:Sendable,
        Delta.Model.CodingKey:Sendable,
        Delta.Model:BSONDecodable
    {
        try await self.run(
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
extension Mongo.Session
{
    //  This should be part of the swift-mongodb package. An incredibly interesting statement,
    //  considering this method is private.
    private
    func explain<Command>(database:Mongo.Database, command:Command) async throws -> String
        where Command:Mongo.Command
    {
        try await self.run(
            command: Mongo.Explain<Command>.init(verbosity: .executionStats, command: command),
            against: database)
    }

    public
    func explain(database:Mongo.Database, query:some Mongo.PipelineQuery) async throws -> String
    {
        try await self.explain(database: database, command: query.command(stride: nil))
    }

    public
    func explain(database:Mongo.Database, update:some Mongo.UpdateQuery) async throws -> String
    {
        try await self.explain(database: database, command: update.command)
    }
}
