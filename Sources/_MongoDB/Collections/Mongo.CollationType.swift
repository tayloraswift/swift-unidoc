import MongoDB

extension Mongo
{
    /// A type that specifies a ``Collation``.
    ///
    /// The main motivation for using types to model collations is to help ensure all
    /// participating components of a query builder are using the same collation.
    public
    protocol CollationType
    {
        static
        var spec:Collation { get }
    }
}
