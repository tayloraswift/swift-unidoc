import BSON
import MongoDB
import MongoQL
import UnidocDB
import UnidocRecords

extension Unidoc
{
    struct AliasResolutionQuery<Aliases, Targets>:Sendable
        where   Aliases:Mongo.CollectionModel,
                Aliases.Element:MongoMasterCodingModel<Unidoc.AliasKey>,
                Targets:Mongo.CollectionModel,
                Targets.Element:BSONDecodable
    {
        let symbol:Aliases.Element.ID

        init(symbol:Aliases.Element.ID)
        {
            self.symbol = symbol
        }
    }
}
extension Unidoc.AliasResolutionQuery:Mongo.PipelineQuery
{
    typealias Iteration = Mongo.Single<Targets.Element>
}
extension Unidoc.AliasResolutionQuery:Unidoc.AliasingQuery
{
    typealias CollectionOrigin = Aliases
    typealias CollectionTarget = Targets

    static
    var target:Mongo.KeyPath { "_id" }

    func extend(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline[.replaceWith] = Self.target
    }
}
