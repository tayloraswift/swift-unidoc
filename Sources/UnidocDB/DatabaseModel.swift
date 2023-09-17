import MongoDB
import MongoQL

public
protocol DatabaseModel:Identifiable<Mongo.Database>, Equatable, Sendable
{
    static
    var collation:Mongo.Collation { get }

    init(id:Mongo.Database)

    func setup(with session:Mongo.Session) async throws
}
extension DatabaseModel
{
    @inlinable public static
    var collation:Mongo.Collation
    {
        .init(locale: "simple", normalization: true) // normalize unicode on insert
    }
}
extension DatabaseModel
{
    public static
    func setup(as id:Mongo.Database, in pool:__owned Mongo.SessionPool) async -> Self
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
extension DatabaseModel
{
    //  This should be part of the swift-mongodb package.
    func explain<Command>(command:__owned Command,
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
    func explain<Query>(query:__owned Query,
        with session:Mongo.Session) async throws -> String
        where Query:DatabaseQuery
    {
        try await self.explain(command: query.command, with: session)
    }

    @inlinable public
    func execute<Query>(query:__owned Query,
        with session:Mongo.Session) async throws -> Query.Output?
        where Query:DatabaseQuery
    {
        try await session.run(command: query.command, against: self.id)
    }
}
