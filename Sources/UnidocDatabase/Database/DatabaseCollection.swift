import BSONDecoding
import BSONEncoding
import MongoDB
import Unidoc
import UnidocRecords

protocol DatabaseCollection<ElementID>
{
    associatedtype ElementID:BSONDecodable, BSONEncodable

    static
    var name:Mongo.Collection { get }
    static
    var indexes:[Mongo.CreateIndexStatement] { get }

    var database:Mongo.Database { get }
}
extension DatabaseCollection
{
    /// Creates any necessary indexes for this collection.
    func setup(with session:Mongo.Session) async throws
    {
        let statements:[Mongo.CreateIndexStatement] = Self.indexes
        if  statements.isEmpty
        {
            return
        }

        do
        {
            let response:Mongo.CreateIndexesResponse = try await session.run(
                command: Mongo.CreateIndexes.init(Self.name,
                    writeConcern: .majority,
                    indexes: statements),
                against: self.database)

            if  response.indexesAfter == statements.count + 1
            {
                return
            }
        }
        catch let error
        {
            print(error)
        }

        print("warning: dropping and recreating ALL indexes in \(Self.name)")

        try await session.run(
            command: Mongo.DropIndexes.init(Self.name)
            {
                $0[.index] = "*"
            },
            against: self.database)

        let response:Mongo.CreateIndexesResponse = try await session.run(
            command: Mongo.CreateIndexes.init(Self.name,
                writeConcern: .majority,
                indexes: statements),
            against: self.database)

        assert(response.indexesAfter == statements.count + 1)
    }
}
extension DatabaseCollection
{
    func find<Decodable>(_:Decodable.Type = Decodable.self,
        by id:ElementID,
        with session:Mongo.Session) async throws -> Decodable?
        where Decodable:BSONDocumentDecodable
    {
        let response:[Decodable] = try await session.run(
            command: Mongo.Find<Mongo.SingleBatch<Decodable>>.init(Self.name,
                limit: 1)
            {
                $0[.filter] = .init
                {
                    $0["_id"] = id
                }
            },
            against: self.database)

        return response.first
    }
}

extension DatabaseCollection
{
    func insert(
        _ elements:some Collection<some BSONDocumentEncodable & Identifiable<ElementID>>,
        with session:Mongo.Session) async throws
    {
        if  elements.isEmpty
        {
            return
        }
        let response:Mongo.InsertResponse = try await session.run(
            command: Mongo.Insert.init(Self.name,
                writeConcern: .majority,
                encoding: elements)
            {
                $0[.ordered] = false
            },
            against: self.database)

        if  response.inserted != elements.count
        {
            throw response.error
        }
    }
}
extension DatabaseCollection
{
    func insert(_ element:some BSONDocumentEncodable & Identifiable<ElementID>,
        with session:Mongo.Session) async throws
    {
        let response:Mongo.InsertResponse = try await session.run(
            command: Mongo.Insert.init(Self.name,
                writeConcern: .majority,
                encoding: [element]),
            against: self.database)

        if  response.inserted != 1
        {
            throw response.error
        }
    }
}

extension DatabaseCollection
{
    func upsert(_ element:some BSONDocumentEncodable & Identifiable<ElementID>,
        with session:Mongo.Session) async throws
    {
        let response:Mongo.UpdateResponse<ElementID> = try await session.run(
            command: Mongo.Update<Mongo.One, ElementID>.init(Self.name,
                updates:
                [
                    .init
                    {
                        $0[.upsert] = true
                        $0[.u] = element
                        $0[.q] = .init { $0["_id"] = element.id }
                    },
                ]),
            against: self.database)

        if  let error:any Error =
                response.writeConcernError ??
                response.writeErrors.first
        {
            throw error
        }
    }
}

extension DatabaseCollection
{
    func delete(_ id:ElementID, with session:Mongo.Session) async throws
    {
        let response:Mongo.DeleteResponse = try await session.run(
            command: Mongo.Delete<Mongo.One>.init(Self.name,
                deletes:
                [
                    .init
                    {
                        $0[.limit] = .one
                        $0[.q] = .init { $0["_id"] = id }
                    },
                ]),
            against: self.database)

        if  let error:any Error =
                response.writeConcernError ??
                response.writeErrors.first
        {
            throw error
        }
    }
}
extension DatabaseCollection<Unidoc.Scalar>
{
    /// Deletes all records from the collection within the specified zone.
    func clear(_ zone:Unidoc.Zone, with session:Mongo.Session) async throws
    {
        let response:Mongo.DeleteResponse = try await session.run(
            command: Mongo.Delete<Mongo.Many>.init(Self.name,
                deletes:
                [
                    .init
                    {
                        $0[.limit] = .unlimited
                        $0[.q] = .init
                        {
                            $0[.and] = .init
                            {
                                $0.append
                                {
                                    $0["_id"] = .init
                                    {
                                        $0[.gte] = zone.min
                                    }
                                }
                                $0.append
                                {
                                    $0["_id"] = .init
                                    {
                                        $0[.lte] = zone.max
                                    }
                                }
                            }
                        }
                    },
                ]),
            against: self.database)

        if  let error:any Error =
                response.writeConcernError ??
                response.writeErrors.first
        {
            throw error
        }
    }
}
extension DatabaseCollection
{
    /// Drops the collection and reinitializes it by calling ``setup(with:)``.
    func replace(with session:Mongo.Session) async throws
    {
        try await session.run(
            command: Mongo.Drop.init(Self.name),
            against: self.database)
        try await self.setup(with: session)
    }
}
