import MongoDB

@frozen public
struct AccountDatabase
{
    public
    let id:Mongo.Database

    @inlinable public
    init(id:Mongo.Database)
    {
        self.id = id
    }
}
extension AccountDatabase
{
    @inlinable public
    var users:Users { .init(database: self.id) }
}
extension AccountDatabase:DatabaseModel
{
    public
    func setup(with session:Mongo.Session) async throws
    {
        try await self.users.setup(with: session)
    }
}
