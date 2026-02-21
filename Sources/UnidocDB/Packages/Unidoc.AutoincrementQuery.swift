import BSON
import MongoQL
import UnidocRecords

extension Unidoc {
    struct AutoincrementQuery<Aliases, Targets>: Sendable
        where   Aliases: Mongo.CollectionModel,
        Aliases.Element: Mongo.MasterCodingModel<Unidoc.AliasKey>,
        Targets: Mongo.CollectionModel,
        Targets.Element: BSONDecodable {
        private let symbol: Aliases.Element.ID

        init(symbol: Aliases.Element.ID) {
            self.symbol = symbol
        }
    }
}
extension Unidoc.AutoincrementQuery: Mongo.PipelineQuery {
    typealias Iteration = Mongo.Single<Unidoc.Autoincrement<Targets.Element>>

    var collation: Mongo.Collation { .simple }
    var from: Mongo.Collection? { Aliases.name }
    var hint: Mongo.CollectionIndex? { nil }

    func build(pipeline: inout Mongo.PipelineEncoder) {
        pipeline[stage: .match] {
            $0[Aliases.Element[.id]] = self.symbol
        }
        pipeline[stage: .replaceWith, using: Output.CodingKey.self] {
            $0[.id] = Aliases.Element[.coordinate]
        }
        pipeline[stage: .lookup] {
            $0[.from] = Targets.name
            $0[.localField] = Output[.id]
            $0[.foreignField] = "_id"
            //  Do not unwind this lookup, because it is possible for alias registration
            //  to succeed while package registration fails, and we need to know that.
            $0[.as] = Output[.document]
        }
        pipeline[stage: .unionWith] = .init {
            $0[.collection] = Aliases.name
            $0[.pipeline] = .init {
                $0[stage: .sort, using: Aliases.Element.CodingKey.self] {
                    $0[.coordinate] = (-)
                }

                $0[stage: .limit] = 1

                $0[stage: .replaceWith, using: Output.CodingKey.self] {
                    $0[.id] { $0[.add] = (Aliases.Element[.coordinate], 1) }
                }
            }
        }
        //  Prefer existing registrations, if any.
        pipeline[stage: .sort, using: Output.CodingKey.self] {
            $0[.id] = (+)
        }

        pipeline[stage: .limit] = 1
    }
}
