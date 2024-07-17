import BSON
import MongoQL
import Signatures
import UnidocRecords

extension Mongo.Variable<Unidoc.AnyGroup>
{
    var constraints:Mongo.List<GenericConstraint<Unidoc.Scalar>, Mongo.AnyKeyPath>
    {
        .init(in: self[.constraints])
    }
}
extension Mongo.Variable<Unidoc.ConformingType>
{
    var constraints:Mongo.List<GenericConstraint<Unidoc.Scalar>, Mongo.AnyKeyPath>
    {
        .init(in: self[.constraints])
    }
}
extension Mongo.Variable<Unidoc.Outline>
{
    var scalars:Mongo.Expression
    {
        .expr
        {
            $0[.cond] =
            (
                if: .expr
                {
                    $0[.eq] = ("missing", .expr { $0[.type] = self[.scalar] })
                },
                then: .expr { $0[.coalesce] = (self[.scalars], [] as [Never]) },
                else: [self[.scalar]]
            )
        }
    }
}
