import ModuleGraphs
import MongoDB
import UnidocRecords

extension Database
{
    struct Zones
    {
        let database:Mongo.Database

        init(database:Mongo.Database)
        {
            self.database = database
        }
    }
}
extension Database.Zones:DatabaseCollection
{
    typealias Element = Record.Zone

    static
    var name:Mongo.Collection { "zones" }
}
extension Database.Zones
{
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
                        (\(Record.Zone[.package]),\
                        \(Record.Zone[.version]),\
                        \(Record.Zone[.recency]))
                        """

                        $0[.key] = .init
                        {
                            $0[Record.Zone[.package]] = (+)
                            $0[Record.Zone[.version]] = (+)
                            $0[Record.Zone[.recency]] = (-)
                        }
                    },
                ]),
            against: self.database)

        assert(response.indexesAfter == 2)
    }
}
