import BSON
import MongoDB
import MongoQL
import UnidocDB
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct AliasResolutionQuery<Aliases, Targets>:Sendable
        where   Aliases:Mongo.CollectionModel,
                Aliases.Element:MongoMasterCodingModel<Unidoc.AliasKey>,
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
extension Unidoc.AliasResolutionQuery:Mongo.PipelineQuery
{
    public
    typealias Iteration = Mongo.Single<Targets.Element>
}
extension Unidoc.AliasResolutionQuery:Unidoc.AliasingQuery
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
