import BSON
import MongoDB
import Unidoc
import UnidocRecords

extension Mongo
{
    public
    protocol CollectionModel<Element>
    {
        associatedtype Element:Identifiable, Sendable where
            Element.ID:BSONDecodable,
            Element.ID:BSONEncodable,
            Element.ID:Sendable

        associatedtype Capacity

        static
        var name:Collection { get }

        static
        var indexes:[CollectionIndex] { get }

        var capacity:Capacity { get }

        var database:Database { get }

        func setup(with session:Session) async throws
    }
}
extension Mongo.CollectionModel where Capacity == Never
{
    @inlinable public
    var capacity:Never { fatalError() }

    public
    func setup(with session:Mongo.Session) async throws
    {
        try await self.setupIndexes(with: session)
    }
}
extension Mongo.CollectionModel where Capacity == (bytes:Int, count:Int?)
{
    public
    func setup(with session:Mongo.Session) async throws
    {
        try await self.setupCapacity(with: session)
        try await self.setupIndexes(with: session)
    }

    private
    func setupCapacity(with session:Mongo.Session) async throws
    {
        let capacity:(bytes:Int, count:Int?) = self.capacity

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
        catch let error as Mongo.ServerError where error.code == 26
        {
            try await session.run(
                command: Mongo.Create<Mongo.Collection>.init(Self.name)
                {
                    $0[.cap] = (size: capacity.bytes, max: capacity.count)
                },
                against: self.database)
        }
    }
}
extension Mongo.CollectionModel where Capacity == (bytes:Int, count:Int?)
{
    func find<Decodable>(_:Decodable.Type = Decodable.self,
        last count:Int,
        with session:Mongo.Session) async throws -> [Decodable]
        where   Decodable:BSONDocumentDecodable,
                Decodable:Sendable
    {
        try await session.run(
            command: Mongo.Find<Mongo.SingleBatch<Decodable>>.init(Self.name,
                limit: count)
            {
                $0[.sort] { $0[.natural] = (-) }
            },
            against: self.database)
    }
}
extension Mongo.CollectionModel
{
    /// Creates any necessary indexes for this collection. Do not call this directly; call
    /// the ``setup(with:)`` method instead. (Unless you are ``setup(with:)``.)
    private
    func setupIndexes(with session:Mongo.Session, dropUnused:Bool = false) async throws
    {
        let indexes:[Mongo.CollectionIndex] = Self.indexes
        if  indexes.isEmpty
        {
            return
        }

        var indexesNeeded:[String: Mongo.CollectionIndex] = Self.indexes.reduce(into: [:])
        {
            $0[$1.id] = $1
        }
        let indexesUnused:[String]
        do
        {
            indexesUnused = try await session.run(
                command: Mongo.ListIndexes.init(Self.name),
                against: self.database)
            {
                try await $0.reduce(into: [])
                {
                    for index:Mongo.IndexBinding in $1
                    {
                        if  case _? = indexesNeeded.removeValue(forKey: index.name)
                        {
                            print("DEBUG: index '\(Self.name):\(index.name)' already exists")
                        }
                        else if index.name != "_id_"
                        {
                            $0.append(index.name)
                        }
                    }
                }
            }
        }
        catch let error as Mongo.ServerError where error.code == 26
        {
            //  Collection has not been created yet.
            indexesUnused = []
        }

        try await self.create(indexes: indexesNeeded, with: session)

        guard dropUnused
        else
        {
            if !indexesUnused.isEmpty
            {
                print("WARNING: unused indexes (\(indexesUnused)) in \(Self.name)")
            }

            return
        }

        try await self.drop(indexes: indexesUnused, with: session)
    }

    private
    func create(indexes:[String: Mongo.CollectionIndex],
        with session:Mongo.Session) async throws
    {
        if  indexes.isEmpty
        {
            return
        }

        let indexes:[Mongo.CollectionIndex] = indexes.values.sorted { $0.id < $1.id }
        let response:Mongo.CreateIndexesResponse
        do
        {
            print("DEBUG: creating indexes (\(indexes.map(\.id))) in \(Self.name)")

            response = try await session.run(command: Mongo.CreateIndexes.init(Self.name,
                    writeConcern: .majority,
                    indexes: indexes.map { .init(with: $0.build(statement:)) }),
                against: self.database)

        }
        catch let error
        {
            print("ERROR: failed to create indexes in \(Self.name)")
            print(error)
            return
        }

        if  response.indexesAfter - response.indexesBefore == indexes.count
        {
            //  Okay, all expected indexes are present, plus the `_id_` index.
            return
        }
        else
        {
            print("ERROR: failed to create indexes in \(Self.name)")
        }
    }

    private
    func drop(indexes:[String], with session:Mongo.Session) async throws
    {
        if  indexes.isEmpty
        {
            return
        }

        try await session.run(
            command: Mongo.DropIndexes.init(Self.name) { $0[.index] = indexes },
            against: self.database)
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
extension Mongo.CollectionModel where Element:BSONDocumentDecodable
{
    @inlinable public
    func find(id:Element.ID, with session:Mongo.Session) async throws -> Element?
    {
        try await self.find(by: "_id", of: id, with: session)
    }
}
extension Mongo.CollectionModel
{
    @inlinable
    func find<Decodable>(_:Decodable.Type = Decodable.self,
        by index:Mongo.AnyKeyPath,
        of key:__owned some BSONEncodable,
        with session:Mongo.Session) async throws -> Decodable?
        where   Decodable:BSONDocumentDecodable,
                Decodable:Sendable
    {
        let response:[Decodable] = try await session.run(
            command: Mongo.Find<Mongo.SingleBatch<Decodable>>.init(Self.name,
                limit: 1)
            {
                $0[.filter]
                {
                    $0[index] = key
                }
                $0[.hint]
                {
                    $0[index] = (+)
                }
            },
            against: self.database)

        return response.first
    }
}

extension Mongo.CollectionModel
    where Element:BSONDecodable, Element.ID:BSONEncodable & Comparable
{
    /// Queries the **primary** replica for up to `limit` documents in this collection, ordered
    /// by `_id`, and starting after the specified identifier if non-nil.
    ///
    /// This is useful for implementing application-level cursors when starting a native mongod
    /// cursor on every application run is not desirable.
    ///
    /// You should **always** call this in a loop with a cooldown, to avoid spinning when the
    /// collection is empty.
    @inlinable public
    func pull(_ limit:Int,
        after cursor:inout Element.ID?,
        with session:Mongo.Session) async throws -> [Element]
    {
        let elements:[Element] = try await session.run(
            command: Mongo.Find<Mongo.SingleBatch<Element>>.init(Self.name, limit: limit)
            {
                $0[.filter]
                {
                    $0["_id"]
                    {
                        if  let cursor:Element.ID
                        {
                            $0[.gt] = cursor
                        }
                        else
                        {
                            $0[.gte] = BSON.Min.init()
                        }
                    }
                }
                $0[.sort]
                {
                    $0["_id"] = (+)
                }
                $0[.hint]
                {
                    $0["_id"] = (+)
                }
            },
            against: self.database)

        if  let last:Element = elements.last
        {
            cursor = last.id
        }
        else
        {
            cursor = nil
        }

        return elements
    }
}
extension Mongo.CollectionModel
{
    /// Decode and re-encode all documents in this collection using the specified master type.
    func recode<Master>(through _:Master.Type = Master.self,
        stride:Int = 4096,
        with session:Mongo.Session,
        by deadline:ContinuousClock.Instant) async throws -> (modified:Int, of:Int)
        where   Master:BSONDocumentDecodable,
                Master:BSONDocumentEncodable,
                Master:Identifiable<Element.ID>,
                Master:Sendable
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
                let updates:Mongo.Updates<Element.ID> = try await self.update(some: batch,
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
        where   Master:BSONDocumentDecodable,
                Master:BSONDocumentEncodable,
                Master:Identifiable<Element.ID>,
                Master:Sendable
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
extension Mongo.CollectionModel
{
    func insert(
        some elements:some Collection<some BSONDocumentEncodable & Identifiable<Element.ID>>,
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
extension Mongo.CollectionModel
{
    func insert(
        some element:some BSONDocumentEncodable & Identifiable<Element.ID>,
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

extension Mongo.CollectionModel
{
    func upsert(
        some elements:some Sequence<some BSONDocumentEncodable & Identifiable<Element.ID>>,
        with session:Mongo.Session) async throws -> Mongo.Updates<Element.ID>
    {
        let response:Mongo.UpdateResponse<Element.ID> = try await session.run(
            command: Mongo.Update<Mongo.One, Element.ID>.init(Self.name)
            {
                for element:some BSONDocumentEncodable & Identifiable<Element.ID> in elements
                {
                    $0.upsert(element)
                }
            },
            against: self.database)

        return try response.updates()
    }

    @discardableResult
    func upsert(
        some element:some BSONDocumentEncodable & Identifiable<Element.ID>,
        with session:Mongo.Session) async throws -> Element.ID?
    {
        let response:Mongo.UpdateResponse<Element.ID> = try await session.run(
            command: Mongo.Update<Mongo.One, Element.ID>.init(Self.name)
            {
                $0.upsert(element)
            },
            against: self.database)

        let updates:Mongo.Updates<Element.ID> = try response.updates()
        return updates.upserted.first?.id
    }
}

extension Mongo.CollectionModel
{
    func update(
        some elements:some Sequence<some BSONDocumentEncodable & Identifiable<Element.ID>>,
        with session:Mongo.Session) async throws -> Mongo.Updates<Element.ID>
    {
        let response:Mongo.UpdateResponse<Element.ID> = try await session.run(
            command: Mongo.Update<Mongo.One, Element.ID>.init(Self.name)
            {
                for element:some BSONDocumentEncodable & Identifiable<Element.ID> in elements
                {
                    $0.replace(element)
                }
            },
            against: self.database)

        return try response.updates()
    }
    /// Replaces an *existing* document having the same identifier as the passed document with
    /// the passed document. Returns true if the document was modified, false if the document
    /// was not modified, and nil if the document was not found.
    @discardableResult
    func update(
        some element:some BSONDocumentEncodable & Identifiable<Element.ID>,
        with session:Mongo.Session) async throws -> Bool?
    {
        let response:Mongo.UpdateResponse<Element.ID> = try await session.run(
            command: Mongo.Update<Mongo.One, Element.ID>.init(Self.name)
            {
                $0.replace(element)
            },
            against: self.database)

        let updates:Mongo.Updates<Element.ID> = try response.updates()
        return updates.selected == 0 ? nil : updates.modified == 1
    }

    /// Sets the value of the specified field in the document with the specified identifier,
    /// returning true if the document was modified, false if the document was not modified,
    /// and nil if the document was not found.
    private
    func update(field:Mongo.AnyKeyPath,
        of target:Element.ID,
        to value:some BSONEncodable,
        with session:Mongo.Session) async throws -> Bool?
    {
        try await self.update(field: field, by: "_id", of: target, to: value, with: session)
    }
    private
    func update(field:Mongo.AnyKeyPath,
        by index:Mongo.AnyKeyPath,
        of key:some BSONEncodable,
        to value:some BSONEncodable,
        with session:Mongo.Session) async throws -> Bool?
    {
        let response:Mongo.UpdateResponse<Element.ID> = try await session.run(
            command: Mongo.Update<Mongo.One, Element.ID>.init(Self.name)
            {
                $0.update(field: field, by: index, of: key, to: value)
            },
            against: self.database)

        let updates:Mongo.Updates<Element.ID> = try response.updates()
        return updates.selected == 0 ? nil : updates.modified == 1
    }
    @inlinable package
    func update(with session:Mongo.Session,
        do encode:(inout Mongo.UpdateListEncoder<Mongo.One>) throws -> ()) async throws -> Bool?
    {
        let response:Mongo.UpdateResponse<Element.ID> = try await session.run(
            command: Mongo.Update<Mongo.One, Element.ID>.init(Self.name)
            {
                try encode(&$0)
            },
            against: self.database)

        let updates:Mongo.Updates<Element.ID> = try response.updates()
        return updates.selected == 0 ? nil : updates.modified == 1
    }
}

extension Mongo.CollectionModel where Element:MongoMasterCodingModel
{
    @discardableResult
    func update(field:Element.CodingKey,
        of target:Element.ID,
        to value:some BSONEncodable,
        with session:Mongo.Session) async throws -> Bool?
    {
        try await self.update(
            field: Element[field],
            of: target,
            to: value,
            with: session)
    }

    @discardableResult
    func update(field:Element.CodingKey,
        by index:Element.CodingKey,
        of key:some BSONEncodable,
        to value:some BSONEncodable,
        with session:Mongo.Session) async throws -> Bool?
    {
        try await self.update(
            field: Element[field],
            by: Element[index],
            of: key,
            to: value,
            with: session)
    }
}

extension Mongo.CollectionModel
{
    /// Deletes up to one document having the specified identifier, returning true if a
    /// document was deleted.
    @discardableResult
    @inlinable public
    func delete(id:Element.ID, with session:Mongo.Session) async throws -> Bool
    {
        try await self.delete(with: session) { $0["_id"] = id }
    }

    @inlinable internal
    func delete(with session:Mongo.Session,
        matching predicate:(inout Mongo.PredicateEncoder) -> ()) async throws -> Bool
    {
        let response:Mongo.DeleteResponse = try await session.run(
            command: Mongo.Delete<Mongo.One>.init(Self.name)
            {
                $0
                {
                    $0[.limit] = .one
                    $0[.q, predicate]
                }
            },
            against: self.database)

        let deletions:Mongo.Deletions = try response.deletions()
        return deletions.deleted != 0
    }

    func deleteAll(with session:Mongo.Session,
        matching predicate:(inout Mongo.PredicateEncoder) -> ()) async throws -> Int
    {
        let response:Mongo.DeleteResponse = try await session.run(
            command: Mongo.Delete<Mongo.Many>.init(Self.name)
            {
                $0
                {
                    $0[.limit] = .unlimited
                    $0[.q, predicate]
                }
            },
            against: self.database)

        let deletions:Mongo.Deletions = try response.deletions()
        return deletions.deleted
    }
}
//  TODO: we need to unify ``Unidoc.Scalar`` and ``Unidoc.Group`, most likely by introducing
//  a new type ``Unidoc.Vertex``.
extension Mongo.CollectionModel // where Element.ID == Unidoc.Scalar
{
    /// Deletes all records from the collection within the specified zone.
    func clear(range:Unidoc.Edition, with session:Mongo.Session) async throws
    {
        let response:Mongo.DeleteResponse = try await session.run(
            command: Mongo.Delete<Mongo.Many>.init(Self.name)
            {
                $0
                {
                    $0[.limit] = .unlimited
                    $0[.q]
                    {
                        $0[.and]
                        {
                            $0 { $0["_id"] { $0[.gte] = range.min } }
                            $0 { $0["_id"] { $0[.lte] = range.max } }
                        }
                    }
                }
            },
            against: self.database)

        let _:Mongo.Deletions = try response.deletions()
    }
}
