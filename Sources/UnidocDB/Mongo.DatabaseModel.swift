import MongoDB
import MongoQL

@available(*, deprecated, renamed: "Mongo.DatabaseModel")
public
typealias DatabaseModel = Mongo.DatabaseModel


extension Mongo
{
    /// A database model is a type that hosts application-specific logic that depends on a
    /// MongoDB database.
    ///
    /// From the perspective of swift code, a ``Mongo.Database`` is just a string name
    /// identifying a database. Therefore, it is often helpful to wrap a ``Mongo.Database``
    /// in an application-specific type to avoid cluttering ``Mongo.Database`` with extensions.
    public
    typealias DatabaseModel = _MongoDatabaseModel
}
/// The name of this protocol is ``Mongo.DatabaseModel``.
public
protocol _MongoDatabaseModel:Identifiable<Mongo.Database>, Equatable, Sendable
{
    init(id:Mongo.Database)

    func setup(with session:Mongo.Session) async throws
}
extension Mongo.DatabaseModel
{
    public static
    func setup(as id:Mongo.Database, in pool:consuming Mongo.SessionPool) async -> Self
    {
        let database:Self = .init(id: id)

        do
        {
            try await database.setup(with: try await .init(from: pool))
        }
        catch let error
        {
            print(error)
            print("""
                warning: some indexes are no longer valid. \
                the database '\(database.id)' likely needs to be rebuilt.
                """)
        }

        return database
    }

    /// Drops and reinitializes the database. This destroys *all* its data!
    public
    func drop(with session:Mongo.Session) async throws
    {
        try await session.run(command: Mongo.DropDatabase.init(), against: self.id)
        try await self.setup(with: session)
    }
}
extension Mongo.DatabaseModel
{
    //  This should be part of the swift-mongodb package.
    func explain<Command>(command:consuming Command,
        with session:Mongo.Session) async throws -> String
        where Command:MongoCommand
    {
        try await session.run(
            command: Mongo.Explain<Command>.init(
                verbosity: .executionStats,
                command: command),
            against: self.id)
    }

    public
    func explain<Query>(query:consuming Query,
        with session:Mongo.Session) async throws -> String
        where Query:Mongo.PipelineQuery, Query.Iteration.Stride == Never?
    {
        try await self.explain(command: query.command, with: session)
    }

    @inlinable public
    func execute<Query>(query:consuming Query,
        with session:Mongo.Session) async throws -> Query.Iteration.Batch
        where Query:Mongo.PipelineQuery, Query.Iteration.Stride == Never?
    {
        try await session.run(command: query.command, against: self.id)
    }
}
extension Mongo.DatabaseModel
{
    public
    func explain(update:consuming some Mongo.UpdateQuery,
        with session:Mongo.Session) async throws -> String
    {
        try await self.explain(command: update.command, with: session)
    }

    @discardableResult
    @inlinable public
    func execute<Query>(update:consuming Query,
        with session:Mongo.Session)
        async throws -> Mongo.UpdateResponse<Query.Target.Element.ID>
        where Query:Mongo.UpdateQuery
    {
        try await session.run(command: update.command, against: self.id)
    }
}
