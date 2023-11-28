import MongoDB

extension Mongo
{
    /// A recodable model is some database abstraction that supports migration to a new schema.
    ///
    /// This protocol does not specify anything about the schema or what the migration actually
    /// entails. It only declares the interface for triggering the migration and reporting its
    /// status. It is most useful for UI layers that need to represent migration operations.
    ///
    /// The most common conformer to this protocol is a ``Mongo.CollectionModel``. But in
    /// theory, anything that supports the concept of a schema migration can conform to this
    /// protocol.
    public
    typealias RecodableModel = _MongoRecodableModel
}

@available(*, deprecated, renamed: "Mongo.RecodableModel")
public
typealias RecodableCollection = Mongo.RecodableModel

/// The name of this protocol is ``Mongo.RecodableModel``.
public
protocol _MongoRecodableModel
{
    func recode(with session:Mongo.Session) async throws -> (modified:Int, of:Int)
}
