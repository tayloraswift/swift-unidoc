import MongoDB

extension DocumentationDatabase
{
    @frozen public
    struct Extensions
    {
        public
        let database:Mongo.Database

        @inlinable internal
        init(database:Mongo.Database)
        {
            self.database = database
        }
    }
}
extension DocumentationDatabase.Extensions
{
    @inlinable public static
    var name:Mongo.Collection { "extensions" }

    func setup(with session:Mongo.Session) async throws
    {
        let response:Mongo.CreateIndexesResponse = try await session.run(
            command: Mongo.CreateIndexes.init(Self.name,
                writeConcern: .majority,
                indexes:
                [
                    .init
                    {
                        $0[.unique] = false
                        $0[.name] = "\(Self.name)(\(Record.Extension[.scope]))"
                        $0[.key] = .init
                        {
                            $0[Record.Extension[.scope]] = (+)
                        }
                    },
                ]),
            against: self.database)

        assert(response.indexesAfter == 2)
    }

    public
    func insert(_ extensions:[Record.Extension], with session:Mongo.Session) async throws
    {
        let response:Mongo.InsertResponse = try await session.run(
            command: Mongo.Insert.init(Self.name,
                writeConcern: .majority,
                encoding: extensions)
            {
                $0[.ordered] = false
            },
            against: self.database)

        if  response.inserted != extensions.count
        {
            throw response.error
        }
    }
}
