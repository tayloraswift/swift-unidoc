import MongoDB
import UnidocRecords

extension Database
{
    @frozen public
    struct Masters
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
extension Database.Masters
{
    @inlinable public static
    var name:Mongo.Collection { "masters" }

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
                        $0[.name] = "\(Self.name)(\(Record.Master[.stem]))"

                        $0[.collation] = DocpageQuery.collation
                        $0[.key] = .init
                        {
                            $0[Record.Master[.stem]] = (+)
                        }
                    },
                ]),
            against: self.database)

        assert(response.indexesAfter == 2)
    }

    public
    func insert(_ masters:Records.Masters, with session:Mongo.Session) async throws
    {
        let response:Mongo.InsertResponse = try await session.run(
            command: Mongo.Insert.init(Self.name,
                writeConcern: .majority,
                encoding: masters)
            {
                $0[.ordered] = false
            },
            against: self.database)

        if  response.inserted != masters.count
        {
            throw response.error
        }
    }
}
