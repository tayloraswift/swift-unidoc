import BSON
import MongoDB

extension Mongo {
    /// A recodable model is some database abstraction that supports migration to a new schema.
    public protocol RecodableModel: CollectionModel
        where Element: BSONDocumentDecodable & BSONDocumentEncodable {
    }
}
extension Mongo.RecodableModel {
    /// Decode and re-encode all documents in this collection using the specified master type.
    @inlinable public func recode(
        stride: Int = 4096,
        by deadline: ContinuousClock.Instant
    ) async throws -> (modified: Int, of: Int) {
        var modified: Int = 0
        var selected: Int = 0
        try await session.run(
            command: Mongo.Find<Mongo.Cursor<Element>>.init(
                Self.name,
                stride: stride,
                limit: .max
            ),
            against: self.database,
            by: deadline
        ) {
            for try await batch: [Element] in $0 {
                let updates: Mongo.Updates<Element.ID> = try await self.replace(batch)

                modified += updates.modified
                selected += updates.selected
            }
        }

        return (modified, selected)
    }

    /// Decode and re-encode all documents in this collection **one at a time** with the
    /// provided closure.
    func recode(
        by deadline: ContinuousClock.Instant,
        _ migrate: (inout Element) async throws -> ()
    ) async throws -> (modified: Int, of: Int) {
        var modified: Int = 0
        var selected: Int = 0
        try await session.run(
            command: Mongo.Find<Mongo.Cursor<Element>>.init(
                Self.name,
                stride: 1,
                limit: .max
            ),
            against: self.database,
            by: deadline
        ) {
            for try await one: [Element] in $0 {
                for var master: Element in consume one {
                    try await migrate(&master)

                    switch try await self.update(some: master) {
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
