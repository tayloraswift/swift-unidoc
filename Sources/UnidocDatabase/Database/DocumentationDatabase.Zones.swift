import ModuleGraphs
import MongoDB

extension DocumentationDatabase
{
    @frozen public
    struct Zones
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
extension DocumentationDatabase.Zones
{
    @inlinable public static
    var name:Mongo.Collection { "zones" }

    func setup(with session:Mongo.Session) async throws
    {
        let response:Mongo.CreateIndexesResponse = try await session.run(
            command: Mongo.CreateIndexes.init(Self.name,
                writeConcern: .majority,
                indexes:
                [
                    .init
                    {
                        $0[.unique] = true
                        $0[.name] =
                        """
                        \(Self.name)\
                        (\(Record[.package]),\(Record[.version]),\(Record[.recency]))
                        """

                        $0[.key] = .init
                        {
                            $0[Record[.package]] = (+)
                            $0[Record[.version]] = (+)
                            $0[Record[.recency]] = (-)
                        }
                    },
                ]),
            against: self.database)

        assert(response.indexesAfter == 2)
    }

    public
    func insert(_ zone:Record.Zone, with session:Mongo.Session) async throws
    {
        let _:Mongo.InsertResponse = try await session.run(
            command: Mongo.Insert.init(Self.name,
                writeConcern: .majority,
                encoding: [zone]),
            against: self.database)
    }
}
