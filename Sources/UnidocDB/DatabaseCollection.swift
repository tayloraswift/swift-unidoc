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
    var capacity:(bytes:Int, count:Int?)? { get }
    static
    var indexes:[Mongo.CreateIndexStatement] { get }

    var database:Mongo.Database { get }
}
extension DatabaseCollection
{
    static
    var capacity:(bytes:Int, count:Int?)? { nil }
}
extension DatabaseCollection
{
    private
    func setup(capacity:(bytes:Int, count:Int?), with session:Mongo.Session) async throws
    {
        do
        {
            try await session.run(
                command: Mongo.Modify<Mongo.Collection>.init(Self.name)
                {
                    $0[.cappedSize] = capacity.bytes
                    $0[.cappedMax] = capacity.count
                },
                against: self.database)
        }
        catch is Mongo.NamespaceError
        {
            try await session.run(
                command: Mongo.Create<Mongo.Collection>.init(Self.name)
                {
                    $0[.cap] = (size: capacity.bytes, max: capacity.count)
                },
                against: self.database)
        }
    }
    /// Creates any necessary indexes for this collection.
    private
    func setup(indexes:[Mongo.CreateIndexStatement], with session:Mongo.Session) async throws
    {
        do
        {
            let response:Mongo.CreateIndexesResponse = try await session.run(
                command: Mongo.CreateIndexes.init(Self.name,
                    writeConcern: .majority,
                    indexes: indexes),
                against: self.database)

            if  response.indexesAfter == indexes.count + 1
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
                indexes: indexes),
            against: self.database)

        assert(response.indexesAfter == indexes.count + 1)

        print("note: recreated \(response.indexesAfter - 1) indexes in \(Self.name)")
    }


    func setup(with session:Mongo.Session) async throws
    {
        if  case (let bytes, let count)? = Self.capacity
        {
            try await self.setup(capacity: (bytes, count), with: session)
        }

        let indexes:[Mongo.CreateIndexStatement] = Self.indexes
        if !indexes.isEmpty
        {
            try await self.setup(indexes: indexes, with: session)
        }
    }

    /// Drops the collection and reinitializes it by calling ``setup(with:)``.
    func replace(with session:Mongo.Session) async throws
    {
        try await session.run(
            command: Mongo.Drop.init(Self.name),
            against: self.database)
        try await self.setup(with: session)
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
    /// Decode and re-encode all documents in this collection using the specified master type.
    func recode<Master>(through _:Master.Type = Master.self,
        stride:Int = 4096,
        with session:Mongo.Session,
        by deadline:ContinuousClock.Instant) async throws -> (modified:Int, of:Int)
        where Master:BSONDocumentDecodable & BSONDocumentEncodable & Identifiable<ElementID>
    {
        var modified:Int = 0
        var selected:Int = 0
        try await session.run(
            command: Mongo.Find<Mongo.Cursor<Master>>.init(Self.name,
                stride: stride,
                limit: .max),
            against: self.database,
            by: deadline)
        {
            for try await batch:[Master] in $0
            {
                let updates:Mongo.Updates<ElementID> = try await self.update(some: batch,
                    with: session)

                modified += updates.modified
                selected += updates.selected
            }
        }

        return (modified, selected)
    }

    /// Decode and re-encode all documents in this collection **one at a time** with the
    /// provided closure.
    func recode<Master>(
        with session:Mongo.Session,
        by deadline:ContinuousClock.Instant,
        _ migrate:(inout Master) async throws -> ()) async throws -> (modified:Int, of:Int)
        where Master:BSONDocumentDecodable & BSONDocumentEncodable & Identifiable<ElementID>
    {
        var modified:Int = 0
        var selected:Int = 0
        try await session.run(
            command: Mongo.Find<Mongo.Cursor<Master>>.init(Self.name,
                stride: 1,
                limit: .max),
            against: self.database,
            by: deadline)
        {
            for try await one:[Master] in $0
            {
                for var master:Master in consume one
                {
                    try await migrate(&master)

                    switch try await self.update(some: master, with: session)
                    {
                    case nil:
                        continue // something raced us.

                    case true?:
                        modified += 1
                        fallthrough

                    case false?:
                        selected += 1
                    }
                }
            }
        }

        return (modified, selected)
    }

}
extension DatabaseCollection
{
    func insert(
        some elements:some Collection<some BSONDocumentEncodable & Identifiable<ElementID>>,
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
    func insert(
        some element:some BSONDocumentEncodable & Identifiable<ElementID>,
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
    func upsert(
        some elements:some Sequence<some BSONDocumentEncodable & Identifiable<ElementID>>,
        with session:Mongo.Session) async throws -> Mongo.Updates<ElementID>
    {
        let response:Mongo.UpdateResponse<ElementID> = try await session.run(
            command: Mongo.Update<Mongo.One, ElementID>.init(Self.name,
                updates: elements.map { .upsert($0) }),
            against: self.database)

        return try response.updates()
    }

    @discardableResult
    func upsert(
        some element:some BSONDocumentEncodable & Identifiable<ElementID>,
        with session:Mongo.Session) async throws -> ElementID?
    {
        let response:Mongo.UpdateResponse<ElementID> = try await session.run(
            command: Mongo.Update<Mongo.One, ElementID>.init(Self.name,
                updates: [.upsert(element)]),
            against: self.database)

        let updates:Mongo.Updates<ElementID> = try response.updates()
        return updates.upserted.first?.id
    }
}

extension DatabaseCollection
{
    func update(
        some elements:some Sequence<some BSONDocumentEncodable & Identifiable<ElementID>>,
        with session:Mongo.Session) async throws -> Mongo.Updates<ElementID>
    {
        let response:Mongo.UpdateResponse<ElementID> = try await session.run(
            command: Mongo.Update<Mongo.One, ElementID>.init(Self.name,
                updates: elements.map { .replace($0) }),
            against: self.database)

        return try response.updates()
    }
    /// Replaces an *existing* document having the same identifier as the passed document with
    /// the passed document. Returns true if the document was modified, false if the document
    /// was not modified, and nil if the document was not found.
    @discardableResult
    func update(
        some element:some BSONDocumentEncodable & Identifiable<ElementID>,
        with session:Mongo.Session) async throws -> Bool?
    {
        let response:Mongo.UpdateResponse<ElementID> = try await session.run(
            command: Mongo.Update<Mongo.One, ElementID>.init(Self.name,
                updates: [.replace(element)]),
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
    /// Deletes up to one document having the specified identifier, returning true if a
    /// document was deleted.
    @discardableResult
    func delete(_ id:ElementID, with session:Mongo.Session) async throws -> Bool
    {
        try await self.delete(with: session)
        {
            $0[Mongo.IdentityView<ElementID>[.id]] = id
        }
    }

    func delete(with session:Mongo.Session,
        matching predicate:(inout Mongo.PredicateDocument) throws -> ()) async throws -> Bool
    {
        let response:Mongo.DeleteResponse = try await session.run(
            command: Mongo.Delete<Mongo.One>.init(Self.name,
                deletes:
                [
                    try .init
                    {
                        $0[.limit] = .one
                        $0[.q] = try .init(with: predicate)
                    },
                ]),
            against: self.database)

        let deletions:Mongo.Deletions = try response.deletions()
        return deletions.deleted != 0
    }

    func deleteAll(with session:Mongo.Session,
        matching predicate:(inout Mongo.PredicateDocument) throws -> ()) async throws -> Int
    {
        let response:Mongo.DeleteResponse = try await session.run(
            command: Mongo.Delete<Mongo.Many>.init(Self.name,
                deletes:
                [
                    try .init
                    {
                        $0[.limit] = .unlimited
                        $0[.q] = try .init(with: predicate)
                    },
                ]),
            against: self.database)

        let deletions:Mongo.Deletions = try response.deletions()
        return deletions.deleted
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
