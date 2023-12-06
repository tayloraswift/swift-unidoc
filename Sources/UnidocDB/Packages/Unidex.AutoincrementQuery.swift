import BSON
import MongoQL
import UnidocRecords

extension Unidex
{
    struct AutoincrementQuery<Aliases, Targets>:Sendable
        where   Aliases:Mongo.CollectionModel,
                Aliases.Element:MongoMasterCodingModel<Unidex.AliasKey>,
                Targets:Mongo.CollectionModel,
                Targets.Element:BSONDecodable
    {
        private
        let symbol:Aliases.Element.ID

        init(symbol:Aliases.Element.ID)
        {
            self.symbol = symbol
        }
    }
}
extension Unidex.AutoincrementQuery:Mongo.PipelineQuery
{
    typealias CollectionOrigin = Aliases
    typealias Collation = SimpleCollation
    typealias Iteration = Mongo.Single<Unidex.Autoincrement<Targets.Element>>

    var hint:Mongo.CollectionIndex? { nil }

    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline[.match] = .init
        {
            $0[Aliases.Element[.id]] = self.symbol
        }
        pipeline[.replaceWith] = .init
        {
            $0[Iteration.BatchElement[.id]] = Aliases.Element[.coordinate]
        }
        pipeline[.lookup] = .init
        {
            $0[.from] = Targets.name
            $0[.localField] = Iteration.BatchElement[.id]
            $0[.foreignField] = "_id"
            //  Do not unwind this lookup, because it is possible for alias registration
            //  to succeed while package registration fails, and we need to know that.
            $0[.as] = Iteration.BatchElement[.document]
        }
        pipeline[.unionWith] = .init
        {
            $0[.collection] = Aliases.name
            $0[.pipeline] = .init
            {
                $0[.sort] = .init
                {
                    $0[Aliases.Element[.coordinate]] = (-)
                }

                $0[.limit] = 1

                $0[.replaceWith] = .init
                {
                    $0[Iteration.BatchElement[.id]] = .expr
                    {
                        $0[.add] = (Aliases.Element[.coordinate], 1)
                    }
                }
            }
        }
        //  Prefer existing registrations, if any.
        pipeline[.sort] = .init
        {
            $0[Iteration.BatchElement[.id]] = (+)
        }

        pipeline[.limit] = 1
    }
}
