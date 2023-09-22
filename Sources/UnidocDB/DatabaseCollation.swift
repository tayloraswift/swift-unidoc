import MongoDB

public
protocol DatabaseCollation
{
    static
    var spec:Mongo.Collation { get }
}
