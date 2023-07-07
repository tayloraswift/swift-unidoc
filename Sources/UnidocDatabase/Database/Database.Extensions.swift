import MongoDB
import Unidoc
import UnidocRecords

extension Database
{
    struct Extensions
    {
        let database:Mongo.Database

        init(database:Mongo.Database)
        {
            self.database = database
        }
    }
}
extension Database.Extensions:DatabaseCollection
{
    typealias Element = Record.Extension

    static
    var name:Mongo.Collection { "extensions" }
}
extension Database.Extensions
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
}
