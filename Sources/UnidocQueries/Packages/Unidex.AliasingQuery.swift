import BSON
import MongoDB
import MongoQL
import Symbols
import UnidocDB
import UnidocRecords

extension Unidex
{
    public
    typealias AliasingQuery = _UnidexAliasingQuery
}

/// The name of this protocol is ``Unidex.AliasingQuery``.
public
protocol _UnidexAliasingQuery<CollectionOrigin, CollectionTarget>:Mongo.PipelineQuery
    where   CollectionOrigin.Element:MongoMasterCodingModel<Unidex.AliasKey>,
            CollectionTarget.Element:BSONDecodable,
            Collation == SimpleCollation
{
    override
    associatedtype CollectionOrigin:Mongo.CollectionModel
    associatedtype CollectionTarget:Mongo.CollectionModel

    /// The field to store the target document (a `CollectionTarget.Element`) in.
    static
    var target:Mongo.KeyPath { get }

    var symbol:CollectionOrigin.Element.ID { get }

    func extend(pipeline:inout Mongo.PipelineEncoder)
}
extension Unidex.AliasingQuery
{
    @inlinable public
    var hint:Mongo.CollectionIndex? { nil }

    public
    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        defer
        {
            self.extend(pipeline: &pipeline)
        }

        pipeline[.match] = .init
        {
            $0[CollectionOrigin.Element[.id]] = self.symbol
        }

        pipeline[.limit] = 1

        pipeline[.lookup] = .init
        {
            $0[.from] = CollectionTarget.name
            $0[.localField] = CollectionOrigin.Element[.coordinate]
            $0[.foreignField] = "_id"
            $0[.as] = Self.target
        }

        pipeline[.project] = .init
        {
            $0[Self.target] = true
        }

        pipeline[.unwind] = Self.target
    }
}
