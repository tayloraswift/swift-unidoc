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
    var users:Users { .init(database: self.id) }
}
extension Account.Database
{
    public static
    func setup(as id:Mongo.Database, in pool:__owned Mongo.SessionPool) async throws -> Self
    {
        let database:Self = .init(id: id)
        try await database.setup(with: try await .init(from: pool))
        return database
    }

    private
    func setup(with session:Mongo.Session) async throws
    {
        do
        {
            try await self.users.setup(with: session)
        }
        catch let error
        {
            print("""
                warning: some indexes are no longer valid. \
                the database '\(self.id)' likely needs to be rebuilt.
                """)
            print(error)
        }
    }
}
extension Account.Database
{
    public
    func upsert(account:__owned Account, with session:Mongo.Session) async throws
    {
        try await self.users.upsert(account, with: session)
    }

    public
    func cookie(_ value:String,
        indicates role:Account.Role,
        with session:Mongo.Session) async throws -> Bool
    {
        //  FIXME: we don’t need to return the entire account document here.
        let matches:[Account] = try await session.run(
            command: Mongo.Find<Mongo.SingleBatch<Account>>.init(Users.name, limit: 1)
            {
                $0[.filter] = .init
                {
                    $0[Account[.session]] = value
                    $0[Account[.role]] = role
                }
                $0[.hint] = .init
                {
                    $0[Account[.session]] = (+)
                    $0[Account[.role]] = (+)
                }
            },
            against: self.id)

        return !matches.isEmpty
    }
}
