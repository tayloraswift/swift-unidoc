import MongoDB

extension Account
{
    @frozen public
    struct Database
    {
        public
        let id:Mongo.Database

        @inlinable public
        init(id:Mongo.Database)
        {
            self.id = id
        }
    }
}
extension Account.Database
{
    @inlinable public
    var users:Users { .init(database: self.id) }
}
extension Account.Database:DatabaseModel
{
    public
    func setup(with session:Mongo.Session) async throws
    {
        try await self.users.setup(with: session)
    }
}
