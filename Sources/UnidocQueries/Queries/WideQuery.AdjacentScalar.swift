import MongoQL

extension WideQuery
{
    /// A type that binds an optional ``Unidoc.Scalar``.
    struct AdjacentScalar
    {
        let path:Mongo.KeyPath

        init(in path:Mongo.KeyPath)
        {
            self.path = path
        }
    }
}
extension WideQuery.AdjacentScalar
{
    /// Generates an expression that evaluates to `true` if the field is null or does not exist,
    /// and something that is not `true` otherwise. This expression is suitable for use as a
    /// predicate in a `$cond` expression.
    ///
    /// The way this works is a little bit weird: if ``path`` evaluates to something non-nil,
    /// this evaluates to an integer, which is not a boolean `true`. When used as a predicate,
    /// the `else` branch will be taken. If ``path`` is nil, the predicate evaluates to `true`,
    /// so the `then` branch will be taken.
    var missing:Mongo.Expression
    {
        .expr
        {
            $0[.coalesce] = (self.path, true)
        }
    }
}
