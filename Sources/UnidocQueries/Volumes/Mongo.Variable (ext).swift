import BSON
import MongoQL
import Signatures
import UnidocRecords

extension Mongo.Variable<Unidoc.AnyGroup> {
    var constraints: Mongo.List<GenericConstraint<Unidoc.Scalar>, Mongo.AnyKeyPath> {
        .init(in: self[.constraints])
    }
}
extension Mongo.Variable<Unidoc.ConformingType> {
    var constraints: Mongo.List<GenericConstraint<Unidoc.Scalar>, Mongo.AnyKeyPath> {
        .init(in: self[.constraints])
    }
}
extension Mongo.Variable<Unidoc.Outline> {
    var scalars: Mongo.Expression {
        .expr {
            $0[.cond] {
                $0[.if] { $0[.eq] = ("missing", .expr { $0[.type] = self[.scalar] }) }
                $0[.then] { $0[.coalesce] = (self[.scalars], [] as [Never]) }
                $0[.else] = [self[.scalar]]
            }
        }
    }
}
