import BSON
import MongoQL
import Signatures
import Unidoc
import UnidocRecords

extension Mongo.Variable<Volume.Outline>
{
    var scalars:Mongo.Expression
    {
        .expr
        {
            $0[.coalesce] = (self[.scalars], [] as [Never])
        }
    }
}
extension Mongo.Variable<Unidoc.Group>
{
    var scalars:Mongo.Expression
    {
        .expr
        {
            $0[.concatArrays] = .init
            {
                $0.expr
                {
                    let constraints:
                        Mongo.List<GenericConstraint<Unidoc.Scalar?>, Mongo.KeyPath> = .init(
                        in: self[.conditions])

                    $0[.map] = constraints.map { $0[.nominal] }
                }

                for key:T.CodingKey in
                [
                    .conformances,
                    .features,
                    .nested,
                    .subforms,
                ]
                {
                    $0.expr
                    {
                        $0[.coalesce] = (self[key], [] as [Never])
                    }
                }

                $0.append([self[.culture]])

                for passage:Mongo.KeyPath in
                [
                    self[.overview] / Volume.Passage[.outlines],
                    self[.details] / Volume.Passage[.outlines],
                ]
                {
                    $0.expr
                    {
                        let outlines:Mongo.List<Volume.Outline, Mongo.KeyPath> = .init(
                            in: passage)

                        $0[.reduce] = outlines.flatMap(\.scalars)
                    }
                }

                $0.expr
                {
                    let members:Mongo.List<Volume.Link, Mongo.KeyPath> = .init(
                        in: self[.members])

                    $0[.filter] = members.filter
                    {
                        (link:Mongo.Variable<Volume.Link>) in Mongo.Expression.expr
                        {
                            $0[.eq] = ("objectId", .expr { $0[.type] = link })
                        }
                    }
                }
            }
        }
    }

    var zones:Mongo.Expression
    {
        .expr
        {
            $0[.coalesce] = (self[.zones], [] as [Never])
        }
    }
}
