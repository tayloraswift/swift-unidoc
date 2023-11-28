import MongoDB

extension Mongo
{
    @frozen public
    struct CollectionIndex:Identifiable, Sendable
    {
        /// The name of the index.
        public
        let id:String

        @usableFromInline internal
        var collation:Collation?
        @usableFromInline internal
        var unique:Bool
        @usableFromInline internal
        var fields:SortDocument
        @usableFromInline internal
        var filter:PredicateDocument?

        @inlinable internal
        init(id:String,
            collation:Collation?,
            unique:Bool,
            fields:SortDocument,
            filter:PredicateDocument?)
        {
            self.id = id
            self.collation = collation
            self.unique = unique
            self.fields = fields
            self.filter = filter
        }
    }
}
extension Mongo.CollectionIndex
{
    @inlinable public
    init(_ id:String,
        collation:Mongo.Collation? = nil,
        unique:Bool = false,
        fields:(inout Mongo.SortDocument) -> (),
        where filter:((inout Mongo.PredicateDocument) -> ())? = nil)
    {
        self.init(id: id,
            collation: collation,
            unique: unique,
            fields: .init(with: fields),
            filter: filter.map { .init(with: $0) })
    }
}
extension Mongo.CollectionIndex
{
    func build(statement:inout Mongo.CreateIndexStatement)
    {
        statement[.name] = self.id
        statement[.collation] = self.collation
        statement[.unique] = self.unique
        statement[.key] = self.fields
        statement[.partialFilterExpression] = self.filter
    }
}
