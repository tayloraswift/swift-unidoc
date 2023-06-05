import SymbolGraphs
import MongoDB

extension DocumentationDatabase
{
    @frozen public
    struct Objects
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
extension DocumentationDatabase.Objects
{
    @inlinable public static
    var name:Mongo.Collection { "objects" }

    public
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
                        (\(DynamicObject[.package]), \(DynamicObject[.version]))
                        """
                        $0[.key] = .init
                        {
                            $0[DynamicObject[.package]] = (-)
                            $0[DynamicObject[.version]] = (-)
                        }
                    },
                ]),
            against: self.database)

        assert(response.indexesAfter == 2)
    }

    public
    func push(_ archive:DocumentationArchive,
        for package:Int32,
        as id:String,
        with session:Mongo.Session) async throws -> (version:Int32, overwritten:Bool)
    {
        let result:Mongo.TransactionResult = await session.withSnapshotTransaction(
            writeConcern: .majority)
        {
            try await self.push(archive, for: package, as: id, with: $0)
        }
        return try result()
    }

    func push(_ archive:DocumentationArchive,
        for package:Int32,
        as id:String,
        with transaction:Mongo.Transaction) async throws -> (version:Int32, overwritten:Bool)
    {
        let predecessors:[DynamicObject.Shell] = try await transaction.run(
            command: Mongo.Find<Mongo.SingleBatch<DynamicObject.Shell>>.init(Self.name,
                limit: 1)
            {
                $0[.filter] = .init
                {
                    $0[DynamicObject[.package]] = package
                }
                $0[.sort] = .init
                {
                    $0[DynamicObject[.version]] = (-)
                }
                $0[.hint] = .init
                {
                    $0[DynamicObject[.package]] = (-)
                    $0[DynamicObject[.version]] = (-)
                }
                $0[.projection] = .init
                {
                    $0[DynamicObject[.version]] = true
                }
            },
            against: self.database)

        let predecessor:Int32 = predecessors.first?.version ?? -1
        if  predecessor == .max
        {
            fatalError("unimplemented")
        }

        let object:DynamicObject = .init(id: id,
            package: package,
            version: predecessor + 1,
            metadata: archive.metadata,
            docs: archive.docs)

        let response:Mongo.UpdateResponse<String> = try await transaction.run(
            command: Mongo.Update<Mongo.One, String>.init(Self.name,
                updates: [
                    .init
                    {
                        $0[.upsert] = true
                        $0[.q] = .init
                        {
                            $0[DynamicObject[.id]] = object.id
                        }
                        $0[.u] = object
                    },
                ]),
            against: self.database)

        return (object.version, overwritten: response.upserted.isEmpty)
    }
}
extension DocumentationDatabase.Objects
{
    func load(_ pins:[String], with session:Mongo.Session) async throws -> [DynamicObject]
    {
        try await session.run(
            command: Mongo.Find<Mongo.Cursor<DynamicObject>>.init(Self.name,
                stride: 16,
                limit: 32)
            {
                $0[.filter] = .init
                {
                    $0[DynamicObject[.stable]] = true
                    $0[DynamicObject[.id]] = .init
                    {
                        $0[.in] = pins
                    }
                }
            },
            against: self.database)
        {
            try await $0.reduce(into: [], +=)
        }
    }
}
