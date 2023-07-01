import MongoDB

extension DocumentationDatabase
{
    @frozen public
    struct Masters
    {
        public
        let database:Mongo.Database

        @inlinable internal
        init(database:Mongo.Database)
        {
            self.database = database
        }
    }
}
extension DocumentationDatabase.Masters
{
    @inlinable public static
    var name:Mongo.Collection { "masters" }

    func setup(with session:Mongo.Session) async throws
    {
    }
}
