import BSONDecoding
import MongoDB

public
protocol DatabaseQuery<Output>:Sendable
{
    associatedtype Output:BSONDocumentDecodable

    var pipeline:Mongo.Pipeline { get }
    var hint:Mongo.SortDocument { get }
}
extension DatabaseQuery
{
    @inlinable public
    var command:Mongo.Aggregate<Mongo.Single<Output>>
    {
        .init(Database.Zones.name, pipeline: self.pipeline)
        {
            $0[.collation] = Database.collation
            $0[.hint] = self.hint
        }
    }
}
