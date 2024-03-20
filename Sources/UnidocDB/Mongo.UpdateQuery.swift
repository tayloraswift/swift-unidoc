import BSON
import MongoDB

extension Mongo
{
    public
    protocol UpdateQuery<Target>:Sendable
    {
        /// The collection the update query operates on.
        associatedtype Target:CollectionModel
        associatedtype Effect:WriteEffect

        /// Constructs an update query by adding statements to the given encoder.
        func build(updates:inout UpdateListEncoder<Effect>)

        var ordered:Bool { get }
    }
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
