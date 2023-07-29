import BSONEncoding
import MongoDB
import Unidoc
import UnidocRecords

protocol DatabaseCollection<ElementID>
{
    associatedtype ElementID

    static
    var name:Mongo.Collection { get }

    var database:Mongo.Database { get }

    /// Creates any necessary indexes for this collection. The witness for this
    /// requirement must not assume the collection is empty.
    func setup(with session:Mongo.Session) async throws
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
extension DatabaseCollection where ElementID:BSONEncodable
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
    func insert(
        _ elements:
            __owned some Collection<some BSONDocumentEncodable & Identifiable<ElementID>>,
        with session:Mongo.Session) async throws
    {
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
    func insert(_ element:__owned some BSONDocumentEncodable & Identifiable<ElementID>,
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
