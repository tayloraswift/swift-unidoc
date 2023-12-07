import BSON
import MongoDB
import MongoQL
import UnidocDB
import UnidocRecords

extension Unidex
{
    @frozen public
    struct AliasResolutionQuery<Aliases, Targets>:Sendable
        where   Aliases:Mongo.CollectionModel,
                Aliases.Element:MongoMasterCodingModel<Unidex.AliasKey>,
                Targets:Mongo.CollectionModel,
                Targets.Element:BSONDecodable
    {
        public
        let symbol:Aliases.Element.ID

        @inlinable public
        init(symbol:Aliases.Element.ID)
        {
            self.symbol = symbol
        }
    }
}
extension Unidex.AliasResolutionQuery:Mongo.PipelineQuery
{
    public
    typealias Iteration = Mongo.Single<Targets.Element>
}
extension Unidex.AliasResolutionQuery:Unidex.AliasingQuery
{
    public
    typealias CollectionOrigin = Aliases
    public
    typealias CollectionTarget = Targets

    @inlinable public static
    var target:Mongo.KeyPath { "_id" }

    public
    func extend(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline[.replaceWith] = Self.target
    }
}
