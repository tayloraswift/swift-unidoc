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
extension Unidoc.DB.Users:Mongo.CollectionModel
{
    public
    typealias Element = Unidoc.User

    @inlinable public static
    var name:Mongo.Collection { "Users" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex] { [] }
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
                $0[.hint]
                {
                    $0[Element[.id]] = (+)
                }
                $0[.query]
                {
                    $0[Element[.id]] = user.id
                }
                $0[.update]
                {
                    //  Set the fields individually, to avoid overwriting session cookie and/or
                    //  generated API keys.
                    $0[.set]
                    {
                        $0[Element[.id]] = user.id
                        $0[Element[.level]] = user.level
                        $0[Element[.github]] = user.github
                    }
                    $0[.setOnInsert]
                    {
                        $0[Element[.cookie]] = Int64.random(in: .min ... .max)
                    }
                }
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
}
