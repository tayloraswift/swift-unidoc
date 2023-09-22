import BSONDecoding
import MongoDB

public
protocol DatabaseQuery<Collation, Output>:Sendable
{
    associatedtype Collation:DatabaseCollation
    associatedtype Output:BSONDocumentDecodable

    func build(pipeline:inout Mongo.Pipeline)

    var origin:Mongo.Collection { get }
    var hint:Mongo.SortDocument? { get }
}
extension DatabaseQuery
{
    @inlinable public
    var command:Mongo.Aggregate<Mongo.Single<Output>>
    {
        .init(self.origin, pipeline: .init(with: self.build(pipeline:)))
        {
            $0[.collation] = Collation.spec
            $0[.hint] = self.hint
        }
    }
}
