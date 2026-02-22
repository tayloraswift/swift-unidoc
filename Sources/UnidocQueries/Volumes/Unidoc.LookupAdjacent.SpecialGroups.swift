import BSON
import MongoQL
import Unidoc
import UnidocRecords

extension Unidoc.LookupAdjacent {
    enum SpecialGroups {
        case `default`(Default)
        case protocols
    }
}
extension Unidoc.LookupAdjacent.SpecialGroups {
    static func += (or: inout Mongo.PredicateListEncoder, self: Self) {
        switch self {
        case .protocols:
            break

        case .default(let self):
            or { $0[.expr] { $0[.eq] = (Unidoc.AnyGroup[.id], self.peers) } }
            or { $0[.expr] { $0[.eq] = (Unidoc.AnyGroup[.id], self.topic) } }
        }
    }
}
