import BSON
import MongoDB

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

        static var name:Collection { get }
        static var indexes:[CollectionIndex] { get }

        var capacity:Capacity { get }
        var database:Database { get }
        var session:Session { get }

        func setup() async throws
    }
}
extension Mongo.CollectionModel where Capacity == Never
{
    @inlinable public
    var capacity:Never { fatalError() }

    public
    func setup() async throws
    {
        try await self.setupIndexes()
    }
}
extension Mongo.CollectionModel where Capacity == (bytes:Int, count:Int?)
{
    public
    func setup() async throws
    {
        try await self.setupCapacity()
        try await self.setupIndexes()
    }

    func setupCapacity() async throws
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
extension Mongo.CollectionModel
    where Capacity == (bytes:Int, count:Int?), Element:BSONDecodable
{
    /// Returns the most recent `count` documents in this capped collection, in ascending
    /// natural order. The first element in the returned array is the newest.
    ///
    /// This method is only available for capped collections, as it relies on the natural order
    /// of documents in the collection.
    @inlinable public
    func find(last count:Int) async throws -> [Element]
    {
        try await session.run(
            command: Mongo.Find<Mongo.SingleBatch<Element>>.init(Self.name,
                limit: count)
            {
                $0[.sort, using: BSON.Key.self] { $0[.natural] = (-) }
            },
            against: self.database)
    }
}
extension Mongo.CollectionModel
{
    /// Creates any necessary indexes for this collection. Do not call this directly; call
    /// the ``setup(with:)`` method instead. (Unless you are ``setup(with:)``.)
    private
    func setupIndexes(dropUnused:Bool = false) async throws
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

        try await self.create(indexes: indexesNeeded)

        guard dropUnused
        else
        {
            if !indexesUnused.isEmpty
            {
                print("WARNING: unused indexes (\(indexesUnused)) in \(Self.name)")
            }

            return
        }

        try await self.drop(indexes: indexesUnused)
    }

    private
    func create(indexes:[String: Mongo.CollectionIndex]) async throws
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
    func drop(indexes:[String]) async throws
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
    func replace() async throws
    {
        try await self.session.run(
            command: Mongo.Drop.init(Self.name),
            against: self.database)
        try await self.setup()
    }
}
extension Mongo.CollectionModel where Element:BSONDocumentDecodable
{
    @inlinable public
    func find(id:Element.ID) async throws -> Element?
    {
        try await self.find
        {
            $0[.filter] { $0["_id"] = id }
            $0[.hint] = "_id_"
        }
    }

    @inlinable public
    func find(
        collation:Mongo.Collation? = nil,
        indexName:String? = nil,
        where predicate:(inout Mongo.PredicateEncoder) -> ()) async throws -> Element?
    {
        try await self.find
        {
            $0[.collation] = collation
            $0[.filter, predicate]
            $0[.hint] = indexName
        }
    }

    @inlinable public
    func find(by index:Mongo.CollectionIndex,
        where predicate:(inout Mongo.PredicateEncoder) -> ()) async throws -> Element?
    {
        try await self.find(collation: index.collation, indexName: index.id, where: predicate)
    }

    @inlinable
    func find(_ yield:(inout Mongo.Find<Mongo.Single<Element>>) -> ()) async throws -> Element?
    {
        try await session.run(
            command: Mongo.Find<Mongo.Single<Element>>.init(Self.name, limit: 1, with: yield),
            against: self.database)
    }
}

extension Mongo.CollectionModel
    where Element:BSONDecodable, Element.ID:BSONEncodable
{
    /// Queries the **primary** replica for up to `limit` documents in this collection, ordered
    /// by `_id`, and starting after the specified identifier if non-nil.
    ///
    /// This is useful for implementing application-level cursors when starting a native mongod
    /// cursor on every application run is not desirable. One example of when this could be
    /// useful is when you want to be able to pause iteration for a long period of time — a
    /// native MongoDB cursor would expire after some period of inactivity.
    ///
    /// You should **always** call this in a loop with a cooldown, to avoid spinning when the
    /// collection is empty.
    ///
    /// -   Parameters:
    ///     -   limit:
    ///         The maximum number of documents to return.
    ///
    ///     -   cursor:
    ///         The identifier of the last document returned by a previous call to this
    ///         function, which will be updated to the identifier of the last document returned
    ///         by this call.
    ///
    ///         If no documents are returned, the cursor will be set to nil, even if it was
    ///         initially non-nil.
    @inlinable public
    func pull(_ limit:Int, after cursor:inout Element.ID?) async throws -> [Element]
    {
        let elements:[Element] = try await session.run(
            command: Mongo.Find<Mongo.SingleBatch<Element>>.init(Self.name, limit: limit)
            {
                $0[.filter]
                {
                    if  let cursor:Element.ID
                    {
                        $0["_id"] { $0[.gt] = cursor }
                    }
                }
                $0[.sort, using: Mongo.AnyKeyPath.self] { $0["_id"] = (+) }
                $0[.hint, using: Mongo.AnyKeyPath.self] { $0["_id"] = (+) }
            },
            against: self.database)

        cursor = elements.last?.id

        return elements
    }
}
extension Mongo.CollectionModel
{
    public
    typealias Insertable = BSONDocumentEncodable & Identifiable<Element.ID>

    @inlinable
    func insert(some elements:some Sequence<some Insertable>) async throws
    {
        var count:Int = 0
        let insert:Mongo.Insert = .init(Self.name, writeConcern: .majority)
        {
            $0[.ordered] = false
        }
            documents:
        {
            for element:some Insertable in elements
            {
                $0.append(element)
                count += 1
            }
        }

        if  count == 0
        {
            return
        }

        let response:Mongo.InsertResponse = try await self.session.run(
            command: insert,
            against: self.database)

        let _:Mongo.Insertions = try response.insertions()
    }

    @inlinable
    func insert(some element:some Insertable) async throws
    {
        let response:Mongo.InsertResponse = try await self.session.run(
            command: Mongo.Insert.init(Self.name, writeConcern: .majority)
            {
                $0.append(element)
            },
            against: self.database)

        let _:Mongo.Insertions = try response.insertions()
    }
}
extension Mongo.CollectionModel
{
    @inlinable
    func upsert(
        some elements:some Sequence<some Insertable>) async throws -> Mongo.Updates<Element.ID>
    {
        var count:Int = 0
        let update:Mongo.Update<Mongo.One, Element.ID> = .init(Self.name)
        {
            for element:some BSONDocumentEncodable & Identifiable<Element.ID> in elements
            {
                $0.upsert(element)
                count += 1
            }
        }

        if  count == 0
        {
            return .init(selected: 0, modified: 0, upserted: [])
        }

        let response:Mongo.UpdateResponse<Element.ID> = try await self.session.run(
            command: update,
            against: self.database)

        return try response.updates()
    }

    @inlinable
    func upsert(some element:some Insertable) async throws -> Element.ID?
    {
        let response:Mongo.UpdateResponse<Element.ID> = try await self.session.run(
            command: Mongo.Update<Mongo.One, Element.ID>.init(Self.name)
            {
                $0.upsert(element)
            },
            against: self.database)

        let updates:Mongo.Updates<Element.ID> = try response.updates()
        return updates.upserted.first?.id
    }
}

extension Mongo.CollectionModel where Element:Insertable
{
    /// Inserts a single instance of this collection’s ``Element`` type, which is **not**
    /// expected to already exist in the collection.
    @inlinable public
    func insert(_ element:Element) async throws
    {
        try await self.insert(some: element)
    }

    /// Inserts multiple instances of this collection’s ``Element`` type, **none of which** are
    /// expected to already exist in the collection.
    @inlinable public
    func insert(_ elements:some Sequence<Element>) async throws
    {
        try await self.insert(some: elements)
    }

    /// Inserts a single instance of this collection’s ``Element`` type, which is expected to
    /// replace an **existing** document with the same ``Identifiable/id [8T2WS]``.
    ///
    /// >   Returns:
    ///     True if the document was modified, false if the document was not modified, and nil
    ///     if the document was not found.
    @discardableResult
    @inlinable public
    func replace(_ element:Element) async throws -> Bool?
    {
        try await self.update(some: element)
    }

    /// Inserts multiple instances of this collection’s ``Element`` type, each of which is
    /// expected to replace an **existing** document with the same ``Identifiable/id [8T2WS]``.
    @discardableResult
    @inlinable public
    func replace(_ elements:some Sequence<Element>) async throws -> Mongo.Updates<Element.ID>
    {
        try await self.update(some: elements)
    }

    /// Inserts a single instance of this collection’s ``Element`` type, replacing any existing
    /// document with the same ``Identifiable/id [8T2WS]``.
    @discardableResult
    @inlinable public
    func upsert(_ element:Element) async throws -> Element.ID?
    {
        try await self.upsert(some: element)
    }

    /// Inserts multiple instances of this collection’s ``Element`` type, each of which
    /// potentially replacing an existing document with the same ``Identifiable/id [8T2WS]``.
    @discardableResult
    @inlinable public
    func upsert(_ elements:some Sequence<Element>) async throws -> Mongo.Updates<Element.ID>
    {
        try await self.upsert(some: elements)
    }
}

extension Mongo.CollectionModel where Element:BSONDecodable, Element.ID:BSONEncodable
{
    @inlinable public
    func upsert(id:Element.ID,
        returning phase:Mongo.UpdatePhase = .new,
        update:(inout Mongo.UpdateEncoder) -> ()) async throws -> (state:Element, new:Bool)
    {
        let (element, upserted):(Element, Element.ID?) = try await session.run(
            command: Mongo.FindAndModify<Mongo.Upserting<Element, Element.ID>>.init(Self.name,
                returning: phase)
            {
                $0[.query] { $0["_id"] = id }
                $0[.update, update]
            },
            against: self.database)
        return (element, upserted != nil)
    }

    @inlinable public
    func upsert(
        collation:Mongo.Collation? = nil,
        indexName:String? = nil,
        returning phase:Mongo.UpdatePhase = .new,
        select:(inout Mongo.PredicateEncoder) -> (),
        update:(inout Mongo.UpdateEncoder) -> ()) async throws -> (state:Element, new:Bool)
    {
        let (element, upserted):(Element, Element.ID?) = try await session.run(
            command: Mongo.FindAndModify<Mongo.Upserting<Element, Element.ID>>.init(Self.name,
                returning: phase)
            {
                $0[.collation] = collation
                $0[.hint] = indexName
                $0[.query, select]
                $0[.update, update]
            },
            against: self.database)
        return (element, upserted != nil)
    }

    @inlinable public
    func upsert(by index:Mongo.CollectionIndex,
        returning phase:Mongo.UpdatePhase = .new,
        select:(inout Mongo.PredicateEncoder) -> (),
        update:(inout Mongo.UpdateEncoder) -> ()) async throws -> (state:Element, new:Bool)
    {
        try await self.upsert(
            collation: index.collation,
            indexName: index.id,
            returning: phase,
            select: select,
            update: update)
    }


    @inlinable public
    func modify(id:Element.ID,
        returning phase:Mongo.UpdatePhase = .new,
        update:(inout Mongo.UpdateEncoder) -> ()) async throws -> Element?
    {
        let (element, _):(Element?, Never?) = try await session.run(
            command: Mongo.FindAndModify<Mongo.Existing<Element>>.init(Self.name,
                returning: phase)
            {
                $0[.query] { $0["_id"] = id }
                $0[.update, update]
            },
            against: self.database)
        return element
    }

    @inlinable public
    func modify(
        collation:Mongo.Collation? = nil,
        indexName:String? = nil,
        returning phase:Mongo.UpdatePhase = .new,
        select:(inout Mongo.PredicateEncoder) -> (),
        update:(inout Mongo.UpdateEncoder) -> ()) async throws -> Element?
    {
        let (element, _):(Element?, Never?) = try await session.run(
            command: Mongo.FindAndModify<Mongo.Existing<Element>>.init(Self.name,
                returning: phase)
            {
                $0[.collation] = collation
                $0[.hint] = indexName
                $0[.query, select]
                $0[.update, update]
            },
            against: self.database)
        return element
    }

    @inlinable public
    func modify(by index:Mongo.CollectionIndex,
        returning phase:Mongo.UpdatePhase = .new,
        select:(inout Mongo.PredicateEncoder) -> (),
        update:(inout Mongo.UpdateEncoder) -> ()) async throws -> Element?
    {
        try await self.modify(
            collation: index.collation,
            indexName: index.id,
            returning: phase,
            select: select,
            update: update)
    }


    @inlinable public
    func remove(id:Element.ID) async throws -> Element?
    {
        let (element, _):(Element?, Never?) = try await session.run(
            command: Mongo.FindAndModify<Mongo.Removing<Element>>.init(Self.name,
                returning: .deleted)
            {
                $0[.query] { $0["_id"] = id }
            },
            against: self.database)
        return element
    }

    @inlinable public
    func remove(
        collation:Mongo.Collation? = nil,
        indexName:String? = nil,
        where predicate:(inout Mongo.PredicateEncoder) -> ()) async throws -> Element?
    {
        let (element, _):(Element?, Never?) = try await session.run(
            command: Mongo.FindAndModify<Mongo.Removing<Element>>.init(Self.name,
                returning: .deleted)
            {
                $0[.collation] = collation
                $0[.hint] = indexName
                $0[.query, predicate]
            },
            against: self.database)
        return element
    }

    @inlinable public
    func remove(by index:Mongo.CollectionIndex,
        where predicate:(inout Mongo.PredicateEncoder) -> ()) async throws -> Element?
    {
        try await self.remove(
            collation: index.collation,
            indexName: index.id,
            where: predicate)
    }
}
extension Mongo.CollectionModel
{
    @inlinable
    func update(
        some elements:some Sequence<some Insertable>) async throws -> Mongo.Updates<Element.ID>
    {
        let response:Mongo.UpdateResponse<Element.ID> = try await session.run(
            command: Mongo.Update<Mongo.One, Element.ID>.init(Self.name)
            {
                for element:some Insertable in elements
                {
                    $0.replace(element)
                }
            },
            against: self.database)

        return try response.updates()
    }

    @discardableResult
    @inlinable
    func update(some element:some Insertable) async throws -> Bool?
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
    @inlinable public
    func update(
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

    @inlinable public
    func updateMany(
        do encode:(inout Mongo.UpdateListEncoder<Mongo.Many>) throws -> ()) async throws -> Int
    {
        let response:Mongo.UpdateResponse<Element.ID> = try await session.run(
            command: Mongo.Update<Mongo.Many, Element.ID>.init(Self.name)
            {
                try encode(&$0)
            },
            against: self.database)

        let updates:Mongo.Updates<Element.ID> = try response.updates()
        return updates.modified
    }
}
extension Mongo.CollectionModel
{
    /// Deletes up to one document having the specified identifier, returning true if a
    /// document was deleted.
    @discardableResult
    @inlinable public
    func delete(id:Element.ID) async throws -> Bool
    {
        try await self.delete { $0["_id"] = id }
    }

    @inlinable public
    func delete(
        collation:Mongo.Collation? = nil,
        indexName:String? = nil,
        where predicate:(inout Mongo.PredicateEncoder) -> ()) async throws -> Bool
    {
        let response:Mongo.DeleteResponse = try await session.run(
            command: Mongo.Delete<Mongo.One>.init(Self.name)
            {
                $0
                {
                    $0[.limit] = .one

                    $0[.collation] = collation
                    $0[.hint] = indexName
                    $0[.q, predicate]
                }
            },
            against: self.database)

        let deletions:Mongo.Deletions = try response.deletions()
        return deletions.deleted != 0
    }

    @inlinable public
    func delete(by index:Mongo.CollectionIndex,
        where predicate:(inout Mongo.PredicateEncoder) -> ()) async throws -> Bool
    {
        try await self.delete(collation: index.collation, indexName: index.id, where: predicate)
    }


    @inlinable public
    func deleteAll(
        collation:Mongo.Collation? = nil,
        indexName:String? = nil,
        where predicate:(inout Mongo.PredicateEncoder) -> ()) async throws -> Int
    {
        let response:Mongo.DeleteResponse = try await session.run(
            command: Mongo.Delete<Mongo.Many>.init(Self.name)
            {
                $0
                {
                    $0[.limit] = .unlimited

                    $0[.collation] = collation
                    $0[.hint] = indexName
                    $0[.q, predicate]
                }
            },
            against: self.database)

        let deletions:Mongo.Deletions = try response.deletions()
        return deletions.deleted
    }

    @inlinable public
    func deleteAll(by index:Mongo.CollectionIndex,
        where predicate:(inout Mongo.PredicateEncoder) -> ()) async throws -> Int
    {
        try await self.deleteAll(
            collation: index.collation,
            indexName: index.id,
            where: predicate)
    }
}
