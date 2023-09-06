import MongoDB
import MongoQL

extension Account.Database
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
extension Account.Database.Users:DatabaseCollection
{
    @inlinable public static
    var name:Mongo.Collection { "users" }

    typealias ElementID = Account.ID

    static
    let indexes:[Mongo.CreateIndexStatement] = []
}
extension Account.Database.Users
{
    public
    func validate(cookie:String, with session:Mongo.Session) async throws -> Account.Role?
    {
        if  let separator:String.Index = cookie.firstIndex(of: ":"),
            let account:Account.ID = .init(cookie[..<separator]),
            let cookie:UInt64 = .init(cookie[cookie.index(after: separator)...])
        {
            let cookie:Int64 = .init(bitPattern: cookie)
            return try await self.validate(cookie: cookie, from: account, with: session)
        }
        else
        {
            return nil
        }
    }
    private
    func validate(cookie:Int64,
        from account:Account.ID,
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
                    $0[Account[.id]] = account
                    $0[Account[.cookie]] = cookie
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
    func update(account:__owned Account, with session:Mongo.Session) async throws -> String
    {
        let cookie:Int64 = try await self.update(account: account, with: session)
        return "\(account.id):\(UInt64.init(bitPattern: cookie))"
    }

    private
    func update(account:__owned Account, with session:Mongo.Session) async throws -> Int64
    {
        let (upserted, _):(CookieView, Account.ID?) = try await session.run(
            command: Mongo.FindAndModify<Mongo.Upserting<CookieView, Account.ID>>.init(
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
            },
            against: self.database)

        return upserted.cookie
    }
}
