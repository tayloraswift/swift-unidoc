import MongoDB

@frozen public
struct SimpleCollation:DatabaseCollation
{
    @inlinable public static
    var spec:Mongo.Collation
    {
        .init(locale: "simple", normalization: true) // normalize unicode on insert
    }
}
