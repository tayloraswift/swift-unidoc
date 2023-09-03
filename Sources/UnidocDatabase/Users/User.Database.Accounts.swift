import MongoQL

extension User.Database
{
    public
    struct Accounts
    {
        let database:Mongo.Database

        init(database:Mongo.Database)
        {
            self.database = database
        }
    }
}
extension User.Database.Accounts:DatabaseCollection
{
    @inlinable public static
    var name:Mongo.Collection { "accounts" }

    typealias ElementID = User.ID

    static
    var indexes:[Mongo.CreateIndexStatement] { [] }
}
