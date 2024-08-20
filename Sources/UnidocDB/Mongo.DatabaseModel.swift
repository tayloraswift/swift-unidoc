import MongoDB
import MongoQL

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
