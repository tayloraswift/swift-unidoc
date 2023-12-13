import MongoDB
import MongoQL
import UnidocRecords

extension UnidocDatabase
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
extension UnidocDatabase.Users:Mongo.CollectionModel
{
    public
    typealias Element = Unidoc.User

    @inlinable public static
    var name:Mongo.Collection { "Users" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex] { [] }
}
extension UnidocDatabase.Users
{
    public
    func validate(cookie credential:Unidoc.Cookie,
        with session:Mongo.Session) async throws -> (Unidoc.User.ID, Unidoc.User.Level)?
    {
        let matches:[LevelView] = try await session.run(
            command: Mongo.Find<Mongo.SingleBatch<LevelView>>.init(Self.name, limit: 1)
            {
                $0[.hint] = .init
                {
                    $0[Element[.id]] = (+)
                }
                $0[.filter] = .init
                {
                    $0[Element[.id]] = credential.user
                    $0[Element[.cookie]] = credential.cookie
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
        with session:Mongo.Session) async throws -> Unidoc.Cookie
    {
        let (upserted, _):(Unidoc.Cookie, Unidoc.User.ID?) = try await session.run(
            command: Mongo.FindAndModify<Mongo.Upserting<Unidoc.Cookie, Unidoc.User.ID>>.init(
                Self.name,
                returning: .new)
            {
                $0[.hint] = .init
                {
                    $0[Element[.id]] = (+)
                }
                $0[.query] = .init
                {
                    $0[Element[.id]] = user.id
                }
                $0[.update] = .init
                {
                    $0[.set] = user
                    $0[.setOnInsert] = .init
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
extension UnidocDatabase.Users
{
    /// Scrambles the cookie for the given user, returning the new cookie. Returns nil if
    /// the user does not exist.
    public
    func scramble(user:Unidoc.User.ID,
        with session:Mongo.Session) async throws -> Unidoc.Cookie?
    {
        let (updated, _):(Unidoc.Cookie?, Never?) = try await session.run(
            command: Mongo.FindAndModify<Mongo.Existing<Unidoc.Cookie>>.init(Self.name,
                returning: .new)
            {
                $0[.hint] = .init
                {
                    $0[Element[.id]] = (+)
                }
                $0[.query] = .init
                {
                    $0[Element[.id]] = user
                }
                $0[.update] = .init
                {
                    $0[.set] = .init
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
