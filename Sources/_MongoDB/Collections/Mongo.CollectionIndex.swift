import MongoDB

extension Mongo {
    @frozen public struct CollectionIndex: Identifiable, Sendable {
        /// The name of the index.
        public let id: String

        public var collation: Collation?
        @usableFromInline var unique: Bool
        @usableFromInline var fields: SortDocument<Mongo.AnyKeyPath>
        @usableFromInline var filter: PredicateDocument?

        @inlinable init(
            id: String,
            collation: Collation?,
            unique: Bool,
            fields: SortDocument<Mongo.AnyKeyPath>,
            filter: PredicateDocument?
        ) {
            self.id = id
            self.collation = collation
            self.unique = unique
            self.fields = fields
            self.filter = filter
        }
    }
}
extension Mongo.CollectionIndex {
    @inlinable public init(
        _ id: String,
        collation: Mongo.Collation? = nil,
        unique: Bool = false,
        fields: (inout Mongo.SortEncoder<Mongo.AnyKeyPath>) -> (),
        where filter: ((inout Mongo.PredicateEncoder) -> ())? = nil
    ) {
        self.init(
            id: id,
            collation: collation,
            unique: unique,
            fields: .init(with: fields),
            filter: filter.map { .init(with: $0) }
        )
    }
}
extension Mongo.CollectionIndex {
    func build(statement: inout Mongo.CreateIndexStatementEncoder) {
        statement[.name] = self.id
        statement[.collation] = self.collation
        statement[.unique] = self.unique
        statement[.key] = self.fields
        statement[.partialFilterExpression] = self.filter
    }
}
