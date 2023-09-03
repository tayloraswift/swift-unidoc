import MongoDB

extension User
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
extension User.Database
{
    var accounts:Accounts { .init(database: self.id) }
}
