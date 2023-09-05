import MongoQL

extension Account.Database
{
    public
    struct Users
    {
        let database:Mongo.Database

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
    let indexes:[Mongo.CreateIndexStatement] =
    [
        .init
        {
            $0[.unique] = true
            $0[.name] = "session,role"
            $0[.key] = .init
            {
                $0[Account[.session]] = (+)
                $0[Account[.role]] = (+)
            }
        },
    ]
}
