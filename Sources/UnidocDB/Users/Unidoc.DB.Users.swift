import MongoDB
import MongoQL
import UnidocRecords

extension Unidoc.DB
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
extension Unidoc.DB.Users
{
    public static
    let indexRateLimit:Mongo.CollectionIndex = .init("RateLimit/2", unique: false)
    {
        $0[Unidoc.User[.apiLimitLeft]] = (+)
    }
}
extension Unidoc.DB.Users:Mongo.CollectionModel
{
    public
    typealias Element = Unidoc.User

    @inlinable public static
    var name:Mongo.Collection { "Users" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex] { [Self.indexRateLimit] }
}
extension Unidoc.DB.Users
{
    /// Checks if the given cookie matches the associated user, returning the user's ID and
    /// access level if the cookie is valid.
    public
    func validate(user:Unidoc.UserSession,
        with session:Mongo.Session) async throws -> Unidoc.User.Level?
    {
        let matches:[LevelView] = try await session.run(
            command: Mongo.Find<Mongo.SingleBatch<LevelView>>.init(Self.name, limit: 1)
            {
                $0[.hint]
                {
                    $0[Element[.id]] = (+)
                }
                $0[.filter]
                {
                    $0[Element[.id]] = user.account
                    $0[Element[.cookie]] = user.cookie
                }
                $0[.projection] = .init
                {
                    $0[Element[.id]] = true
                    $0[Element[.level]] = true
                }
            },
            against: self.database)

        return matches.first?.level
    }

    /// Upserts the given account into the database, returning a new, randomly-generated
    /// session cookie if the account was inserted, or the existing cookie if the account
    /// already exists.
    ///
    /// This function always calls into ``Int64.random(in:)``, which might block the current
    /// thread while it waits for the system to generate a random number. This cookie is only
    /// secure if the system's random number generator is secure.
    public
    func update(user:Unidoc.User,
        with session:Mongo.Session) async throws -> Unidoc.UserSecrets
    {
        let (secrets, _):(Unidoc.UserSecrets, Unidoc.Account?) = try await session.run(
            command: Mongo.FindAndModify<
                Mongo.Upserting<Unidoc.UserSecrets, Unidoc.Account>>.init(Self.name,
                returning: .new)
            {
                $0[.hint] { $0[Element[.id]] = (+) }
                $0[.query] { $0[Element[.id]] = user.id }
                $0[.update] { $0 += user }
                $0[.fields] = .init
                {
                    $0[Element[.id]] = true
                    $0[Element[.cookie]] = true
                    $0[Element[.apiKey]] = true
                }
            },
            against: self.database)

        return secrets
    }

    public
    func update(users:[Unidoc.User],
        with session:Mongo.Session) async throws -> Mongo.Updates<Unidoc.Account>
    {
        let updated:Mongo.UpdateResponse<Unidoc.Account> = try await session.run(
            command: Mongo.Update<Mongo.Many, Unidoc.Account>.init(Self.name)
            {
                for user:Unidoc.User in users
                {
                    $0
                    {
                        $0[.upsert] = true
                        $0[.q] { $0[Element[.id]] = user.id }
                        $0[.u] { $0 += user }
                    }
                }
            },
            against: self.database)

        return try updated.updates()
    }

    /// **Replaces** the access list for the given user with the specified list, returning
    /// true if the user exists and the list was modified from its previous value.
    public
    func update(access:[Unidoc.Account],
        user:Unidoc.Account,
        with session:Mongo.Session) async throws -> Bool?
    {
        try await self.update(field: .access, of: user, to: access, with: session)
    }
}
extension Unidoc.DB.Users
{
    /// Scrambles the specified secret for the given user, returning the new secrets.
    ///
    /// Returns nil if the user does not exist.
    public
    func scramble(secret:Unidoc.User.CodingKey,
        user:Unidoc.Account,
        with session:Mongo.Session) async throws -> Unidoc.UserSecrets?
    {
        let (updated, _):(Unidoc.UserSecrets?, Never?) = try await session.run(
            command: Mongo.FindAndModify<Mongo.Existing<Unidoc.UserSecrets>>.init(Self.name,
                returning: .new)
            {
                $0[.hint]
                {
                    $0[Element[.id]] = (+)
                }
                $0[.query]
                {
                    $0[Element[.id]] = user
                }
                $0[.update]
                {
                    $0[.set]
                    {
                        $0[Element[secret]] = Int64.random(in: .min ... .max)
                    }
                }
                $0[.fields] = .init
                {
                    $0[Element[.cookie]] = true
                    $0[Element[.apiKey]] = true
                }
            },
            against: self.database)

        return updated
    }

    /// Resets API rate limits for up to `limit` users, returning the number of users whose
    /// rate limits were reset.
    public
    func airdrop(
        reset:Int,
        limit:Int,
        with session:Mongo.Session) async throws -> Int
    {
        let accounts:[Mongo.IdentityDocument<Unidoc.Account>] = try await session.run(
            command: Mongo.Find<Mongo.SingleBatch<Mongo.IdentityDocument<Unidoc.Account>>>.init(
                Self.name,
                limit: limit)
            {
                $0[.hint] = Self.indexRateLimit.id
                $0[.filter]
                {
                    $0[Element[.apiLimitLeft]] { $0[.ne] = reset }
                }
                $0[.projection] = .init
                {
                    $0[Element[.id]] = true
                }
            },
            against: self.database)

        if  accounts.isEmpty
        {
            return 0
        }

        let updated:Mongo.UpdateResponse<Unidoc.Account> = try await session.run(
            command: Mongo.Update<Mongo.Many, Unidoc.Account>.init(Self.name)
            {
                //  Not the end of the world if this races something and we airdrop rate limit
                //  to users that lack an API key.
                $0
                {
                    $0[.multi] = true
                    $0[.q]
                    {
                        $0[Element[.id]] { $0[.in] = accounts.lazy.map(\.id) }
                    }
                    $0[.u]
                    {
                        $0[.set] { $0[Element[.apiLimitLeft]] = reset }
                    }
                }
            },
            against: self.database)

        return updated.selected
    }

    /// Charges the given API key by the specified amount, returning the amount of API calls
    /// left after the charge.
    ///
    /// If the key is non-nil, this function only returns a result if the key is active, and so
    /// this method doubles as an authentication check.
    ///
    /// If the key is nil, this function will charge the `user` unconditionally, and so some
    /// other means of authenticating the user must be used.
    public
    func charge(apiKey:Int64?,
        user:Unidoc.Account,
        cost:Int = 1,
        with session:Mongo.Session) async throws -> Int?
    {
        let (meter, _):(Unidoc.UserMeter?, Never?) = try await session.run(
            command: Mongo.FindAndModify<Mongo.Existing<Unidoc.UserMeter>>.init(Self.name,
                returning: .new)
            {
                $0[.hint]
                {
                    $0[Element[.id]] = (+)
                }
                $0[.query]
                {
                    $0[Element[.id]] = user
                    $0[Element[.apiKey]] = apiKey
                    $0[Element[.apiLimitLeft]] { $0[.gte] = cost }
                }
                $0[.update]
                {
                    $0[.inc] { $0[Element[.apiLimitLeft]] = -cost }
                }
                $0[.fields] = .init
                {
                    $0[Element[.apiLimitLeft]] = true
                    $0[Element[.apiKey]] = true
                }
            },
            against: self.database)

        return meter?.apiLimitLeft
    }
}
