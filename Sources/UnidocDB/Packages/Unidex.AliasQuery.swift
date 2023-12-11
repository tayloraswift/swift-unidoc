import BSON
import MongoQL
import UnidocRecords

extension Unidex
{
    /// A query that adds a new alias to the specified `Aliases` collection by looking up and
    /// branching from an existing alias.
    struct AliasQuery<Aliases>:Sendable
        where   Aliases:Mongo.CollectionModel,
                Aliases.Element:MongoMasterCodingModel<Unidex.AliasKey>
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
extension Unidex.AliasQuery:Mongo.PipelineQuery
{
    typealias CollectionOrigin = Aliases
    typealias Collation = SimpleCollation
    typealias Iteration = Mongo.Single<Never>

    var hint:Mongo.CollectionIndex? { nil }

    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline[.match] = .init
        {
            $0[Aliases.Element[.id]] = self.symbol
        }
        pipeline[.set] = .init
        {
            $0[Aliases.Element[.id]] = self.alias
        }
        pipeline[.merge] = .init
        {
            $0[.into] = Aliases.name
            $0[.on] = Aliases.Element[.id]
            $0[.whenNotMatched] = .insert
            $0[.whenMatched] = .fail
        }
    }
}
