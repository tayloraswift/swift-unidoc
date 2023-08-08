import MongoQL

public
protocol DatabaseLookupSelector:Equatable, Hashable, Sendable
{
    func lookup(input:Mongo.KeyPath, as output:Mongo.KeyPath) -> Mongo.LookupDocument
}
