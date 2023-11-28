import MongoDB

@available(*, deprecated, renamed: "Mongo.Collation")
public
typealias DatabaseCollation = Mongo.CollationType

extension Mongo
{
    /// A type that specifies a ``Mongo.Collation``.
    ///
    /// The main motivation for using types to model collations is to help ensure all
    /// participating components of a query builder are using the same collation.
    public
    typealias CollationType = _MongoCollationType
}

/// The name of this protocol is ``Mongo.CollationType``.
public
protocol _MongoCollationType
{
    static
    var spec:Mongo.Collation { get }
}
