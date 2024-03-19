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
        with session:Mongo.Session) async throws -> (Unidoc.Account, Unidoc.User.Level)?
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

        return matches.first.map { ($0.id, $0.level) }
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
        with session:Mongo.Session) async throws -> Unidoc.UserSession
    {
        let (upserted, _):(Unidoc.UserSession, Unidoc.Account?) = try await session.run(
            command: Mongo.FindAndModify<
                Mongo.Upserting<Unidoc.UserSession, Unidoc.Account>>.init(Self.name,
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
                    $0[.set] = user
                    $0[.setOnInsert]
                    {
                        $0[Element[.cookie]] = Int64.random(in: .min ... .max)
                    }
                }
                $0[.fields] = .init
                {
                    $0[Element[.id]] = true
                    $0[Element[.cookie]] = true
                }
            },
            against: self.database)

        return upserted
    }
}
extension Unidoc.DB.Users
{
    /// Scrambles the cookie for the given user, returning the new cookie. Returns nil if
    /// the user does not exist.
    public
    func scramble(user:Unidoc.Account,
        with session:Mongo.Session) async throws -> Unidoc.UserSession?
    {
        let (updated, _):(Unidoc.UserSession?, Never?) = try await session.run(
            command: Mongo.FindAndModify<Mongo.Existing<Unidoc.UserSession>>.init(Self.name,
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
                        $0[Element[.cookie]] = Int64.random(in: .min ... .max)
                    }
                }
                $0[.fields] = .init
                {
                    $0[Element[.id]] = true
                    $0[Element[.cookie]] = true
                }
            },
            against: self.database)

        return updated
    }
}
