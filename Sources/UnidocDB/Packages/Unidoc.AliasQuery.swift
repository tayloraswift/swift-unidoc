import BSON
import MongoQL
import UnidocRecords

extension Unidoc
{
    /// A query that adds a new alias to the specified `Aliases` collection by looking up and
    /// branching from an existing alias. If the alias already exists, the query does nothing.
    struct AliasQuery<Aliases>:Sendable
        where   Aliases:Mongo.CollectionModel,
                Aliases.Element:Mongo.MasterCodingModel<Unidoc.AliasKey>
    {
        private
        let symbol:Aliases.Element.ID
        private
        let alias:Aliases.Element.ID

        init?(symbol:Aliases.Element.ID, alias:Aliases.Element.ID)
        {
            if  symbol == alias
            {
                return nil
            }

            self.symbol = symbol
            self.alias = alias
        }
    }
}
extension Unidoc.AliasQuery:Mongo.PipelineQuery
{
    typealias CollectionOrigin = Aliases
    typealias Iteration = Mongo.Single<Never>

    var collation:Mongo.Collation { .simple }
    var hint:Mongo.CollectionIndex? { nil }

    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline[stage: .match]
        {
            $0[Aliases.Element[.id]] = self.symbol
        }
        pipeline[stage: .set, using: Aliases.Element.CodingKey.self]
        {
            $0[.id] = self.alias
        }
        pipeline[stage: .merge] = .init
        {
            $0[.into] = Aliases.name
            $0[.on] = Aliases.Element[.id]
            $0[.whenNotMatched] = .insert
            $0[.whenMatched] = .keepExisting
        }
    }
}
