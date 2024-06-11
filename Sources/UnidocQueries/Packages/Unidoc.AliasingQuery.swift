import BSON
import MongoDB
import MongoQL
import Symbols
import UnidocDB
import UnidocRecords

extension Unidoc
{
    public
    protocol AliasingQuery<CollectionOrigin, CollectionTarget>:Mongo.PipelineQuery
        where   CollectionOrigin.Element:Mongo.MasterCodingModel<AliasKey>,
                Collation == SimpleCollation
    {
        override
        associatedtype CollectionOrigin:Mongo.CollectionModel
        associatedtype CollectionTarget:Mongo.CollectionModel

        /// The field to store the target document (a `CollectionTarget.Element`) in.
        static
        var target:Mongo.AnyKeyPath { get }

        var symbol:CollectionOrigin.Element.ID { get }

        func extend(pipeline:inout Mongo.PipelineEncoder)
    }
}
extension Unidoc.AliasingQuery
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

        pipeline[stage: .match]
        {
            $0[CollectionOrigin.Element[.id]] = self.symbol
        }

        pipeline[stage: .limit] = 1

        pipeline[stage: .lookup] = .init
        {
            $0[.from] = CollectionTarget.name
            $0[.localField] = CollectionOrigin.Element[.coordinate]
            $0[.foreignField] = "_id"
            $0[.as] = Self.target
        }

        pipeline[stage: .project] = .init
        {
            $0[Self.target] = true
        }

        pipeline[stage: .unwind] = Self.target
    }
}
