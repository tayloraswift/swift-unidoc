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
