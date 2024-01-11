import BSON
import MongoQL
import Signatures
import UnidocRecords

extension Mongo.Variable<Unidoc.AnyGroup>
{
    var constraints:Mongo.List<GenericConstraint<Unidoc.Scalar?>, Mongo.KeyPath>
    {
        .init(in: self[.constraints])
    }
}
extension Mongo.Variable<Unidoc.ConformingType>
{
    var constraints:Mongo.List<GenericConstraint<Unidoc.Scalar?>, Mongo.KeyPath>
    {
        .init(in: self[.constraints])
    }
}
extension Mongo.Variable<Unidoc.Outline>
{
    var scalars:Mongo.Expression
    {
        .expr { $0[.coalesce] = (self[.scalars], [] as [Never]) }
    }
}
