import BSON
import MongoDB

extension Mongo
{
    public
    typealias UpdateQuery = _MongoUpdateQuery
}

/// The name of this protocol is ``Mongo.PipelineQuery``.
public
protocol _MongoUpdateQuery<Target>:Sendable
{
    /// The collection the update query operates on.
    associatedtype Target:Mongo.CollectionModel
    associatedtype Effect:Mongo.WriteEffect

    /// Constructs an update query by adding statements to the given encoder.
    func build(updates:inout Mongo.UpdateEncoder<Effect>)

    var ordered:Bool { get }
}
extension Mongo.UpdateQuery
{
    @inlinable internal
    var command:Mongo.Update<Effect, Target.Element.ID>
    {
        .init(Target.name)
        {
            $0[.ordered] = self.ordered
        }
            updates:
        {
            self.build(updates: &$0)
        }
    }
}
