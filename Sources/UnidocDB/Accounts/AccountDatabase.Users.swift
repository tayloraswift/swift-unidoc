import MongoDB
import MongoQL

extension AccountDatabase
{
    @frozen public
    struct Users
    {
        public
        let database:Mongo.Database

        @inlinable public
        init(database:Mongo.Database)
        {
            self.database = database
        }
    }
}
extension AccountDatabase.Users:Mongo.CollectionModel
{
    @inlinable public static
    var name:Mongo.Collection { "Users" }

    typealias ElementID = Account.ID

    static
    let indexes:[Mongo.CollectionIndex] = []
}
extension AccountDatabase.Users
{
    public
    func validate(cookie credential:Account.Cookie,
        with session:Mongo.Session) async throws -> Account.Role?
    {
        let matches:[RoleView] = try await session.run(
            command: Mongo.Find<Mongo.SingleBatch<RoleView>>.init(Self.name, limit: 1)
            {
                $0[.hint] = .init
                {
                    $0[Account[.id]] = (+)
                }
                $0[.filter] = .init
                {
                    $0[Account[.id]] = credential.id
                    $0[Account[.cookie]] = credential.cookie
                }
                $0[.projection] = .init
                {
                    $0[Account[.role]] = true
                }
            },
            against: self.database)

        return matches.first?.role
    }

    /// Upserts the given account into the database, returning a new, randomly-generated
    /// session cookie if the account was inserted, or the existing cookie if the account
    /// already exists.
    ///
    /// This function always calls into ``Int64.random(in:)``, which might block the current
    /// thread while it waits for the system to generate a random number. This cookie is only
    /// secure if the system's random number generator is secure.
    public
    func update(account:__owned Account,
        with session:Mongo.Session) async throws -> Account.Cookie
    {
        let (upserted, _):(Account.Cookie, Account.ID?) = try await session.run(
            command: Mongo.FindAndModify<Mongo.Upserting<Account.Cookie, Account.ID>>.init(
                Self.name,
                returning: .new)
            {
                $0[.hint] = .init
                {
                    $0[Account[.id]] = (+)
                }
                $0[.query] = .init
                {
                    $0[Account[.id]] = account.id
                }
                $0[.update] = .init
                {
                    $0[.set] = .init
                    {
                        $0[Account[.id]] = account.id
                        $0[Account[.role]] = account.role
                        $0[Account[.user]] = account.user
                    }
                    $0[.setOnInsert] = .init
                    {
                        $0[Account[.cookie]] = Int64.random(in: .min ... .max)
                    }
                }
                $0[.fields] = .init
                {
                    $0[Account[.id]] = true
                    $0[Account[.cookie]] = true
                }
            },
            against: self.database)

        return upserted
    }
}
extension AccountDatabase.Users
{
    /// Scrambles the cookie for the given account, returning the new cookie. Returns nil if
    /// the account does not exist.
    public
    func scramble(account:Account.ID,
        with session:Mongo.Session) async throws -> Account.Cookie?
    {
        let (updated, _):(Account.Cookie?, Never?) = try await session.run(
            command: Mongo.FindAndModify<Mongo.Existing<Account.Cookie>>.init(
                Self.name,
                returning: .new)
            {
                $0[.hint] = .init
                {
                    $0[Account[.id]] = (+)
                }
                $0[.query] = .init
                {
                    $0[Account[.id]] = account
                }
                $0[.update] = .init
                {
                    $0[.set] = .init
                    {
                        $0[Account[.cookie]] = Int64.random(in: .min ... .max)
                    }
                }
                $0[.fields] = .init
                {
                    $0[Account[.id]] = true
                    $0[Account[.cookie]] = true
                }
            },
            against: self.database)

        return updated
    }
}
