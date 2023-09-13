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

        print("note: recreated \(response.indexesAfter - 1) indexes in \(Self.name)")
    }
}
extension DatabaseCollection
{
    func find<Decodable>(_:Decodable.Type = Decodable.self,
        by id:ElementID,
        with session:Mongo.Session) async throws -> Decodable?
        where Decodable:BSONDocumentDecodable
    {
        try await self.find(by: "_id", of: id, with: session)
    }

    func find<Decodable>(_:Decodable.Type = Decodable.self,
        by index:Mongo.KeyPath,
        of key:__owned some BSONEncodable,
        with session:Mongo.Session) async throws -> Decodable?
        where Decodable:BSONDocumentDecodable
    {
        let response:[Decodable] = try await session.run(
            command: Mongo.Find<Mongo.SingleBatch<Decodable>>.init(Self.name,
                limit: 1)
            {
                $0[.filter] = .init
                {
                    $0[index] = key
                }
                $0[.hint] = .init
                {
                    $0[index] = (+)
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

        let _:Mongo.Insertions = try response.insertions()
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

        let _:Mongo.Insertions = try response.insertions()
    }
}

extension DatabaseCollection
{
    @discardableResult
    func upsert(_ element:some BSONDocumentEncodable & Identifiable<ElementID>,
        with session:Mongo.Session) async throws -> ElementID?
    {
        let response:Mongo.UpdateResponse<ElementID> = try await session.run(
            command: Mongo.Update<Mongo.One, ElementID>.init(Self.name,
                updates:
                [
                    .init
                    {
                        $0[.upsert] = true
                        $0[.q] = .init { $0["_id"] = element.id }
                        $0[.u] = element
                    },
                ]),
            against: self.database)

        let updates:Mongo.Updates<ElementID> = try response.updates()
        return updates.upserted.first?.id
    }
}
extension DatabaseCollection
{
    /// Replaces an *existing* document having the same identifier as the passed document with
    /// the passed document. Returns true if the document was modified, false if the document
    /// was not modified, and nil if the document was not found.
    @discardableResult
    func update(_ element:some BSONDocumentEncodable & Identifiable<ElementID>,
        with session:Mongo.Session) async throws -> Bool?
    {
        let response:Mongo.UpdateResponse<ElementID> = try await session.run(
            command: Mongo.Update<Mongo.One, ElementID>.init(Self.name,
                updates:
                [
                    .init
                    {
                        $0[.upsert] = false
                        $0[.q] = .init { $0["_id"] = element.id }
                        $0[.u] = element
                    },
                ]),
            against: self.database)

        let updates:Mongo.Updates<ElementID> = try response.updates()
        return updates.selected == 0 ? nil : updates.modified == 1
    }

    /// Sets the value of the specified field in the document with the specified identifier,
    /// returning true if the document was modified, false if the document was not modified,
    /// and nil if the document was not found.
    @discardableResult
    func update(field:Mongo.KeyPath,
        of target:ElementID,
        to value:__owned some BSONEncodable,
        with session:Mongo.Session) async throws -> Bool?
    {
        try await self.update(field: field, by: "_id", of: target, to: value, with: session)
    }
    @discardableResult
    func update(field:Mongo.KeyPath,
        by index:Mongo.KeyPath,
        of key:__owned some BSONEncodable,
        to value:__owned some BSONEncodable,
        with session:Mongo.Session) async throws -> Bool?
    {
        let response:Mongo.UpdateResponse<ElementID> = try await session.run(
            command: Mongo.Update<Mongo.One, ElementID>.init(Self.name,
                updates:
                [
                    .init
                    {
                        $0[.hint] = .init { $0[index] = (+) }
                        $0[.q] = .init { $0[index] = key }
                        $0[.u] = .init { $0[.set] = .init { $0[field] = value } }
                    },
                ]),
            against: self.database)

        let updates:Mongo.Updates<ElementID> = try response.updates()
        return updates.selected == 0 ? nil : updates.modified == 1
    }
}

extension DatabaseCollection
{
    @discardableResult
    func delete(_ id:ElementID, with session:Mongo.Session) async throws -> Bool
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

        let deletions:Mongo.Deletions = try response.deletions()
        return deletions.deleted != 0
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

        let _:Mongo.Deletions = try response.deletions()
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