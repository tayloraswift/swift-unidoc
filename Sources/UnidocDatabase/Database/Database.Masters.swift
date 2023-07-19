import MongoDB
import Unidoc
import UnidocRecords

extension Database
{
    struct Masters
    {
        let database:Mongo.Database

        init(database:Mongo.Database)
        {
            self.database = database
        }
    }
}
extension Database.Masters:DatabaseCollection
{
    typealias ElementID = Unidoc.Scalar

    static
    var name:Mongo.Collection { "masters" }
}
extension Database.Masters
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
                        $0[.unique] = false
                        $0[.name] = """
                        \(Self.name)(\(Record.Master[.stem]),\(Record.Master[.hash]))
                        """

                        $0[.collation] = DeepQuery.collation
                        $0[.key] = .init
                        {
                            $0[Record.Master[.stem]] = (+)
                            $0[Record.Master[.hash]] = (+)
                        }
                    },
                ]),
            against: self.database)

        assert(response.indexesAfter == 2)
    }
}
