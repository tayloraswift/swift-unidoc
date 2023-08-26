import BSONDecoding
import MongoDB

public
protocol DatabaseQuery<Output>:Sendable
{
    associatedtype Output:BSONDocumentDecodable

    static
    var collection:Mongo.Collection { get }

    var pipeline:Mongo.Pipeline { get }
    var hint:Mongo.SortDocument { get }
}
extension DatabaseQuery
{
    @inlinable public
    var command:Mongo.Aggregate<Mongo.Single<Output>>
    {
        .init(Self.collection, pipeline: self.pipeline)
        {
            $0[.collation] = Database.collation
            $0[.hint] = self.hint
        }
    }
}
