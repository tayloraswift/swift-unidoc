import BSONEncoding
import MongoBuiltins
import MongoExpressions
import MongoSchema
import Signatures
import Unidoc
import UnidocRecords

extension Mongo.Variable<Record.Outline>
{
    var scalars:MongoExpression
    {
        .expr
        {
            $0[.coalesce] = (self[.scalars], [] as [Never])
        }
    }
}
extension Mongo.Variable<Record.Group>
{
    var scalars:MongoExpression
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
                    self[.overview] / Record.Passage[.outlines],
                    self[.details] / Record.Passage[.outlines],
                ]
                {
                    $0.expr
                    {
                        let outlines:Mongo.List<Record.Outline, Mongo.KeyPath> = .init(
                            in: passage)

                        $0[.reduce] = outlines.flatMap(\.scalars)
                    }
                }

                $0.expr
                {
                    let members:Mongo.List<Record.Link, Mongo.KeyPath> = .init(
                        in: self[.members])

                    $0[.filter] = members.filter
                    {
                        (link:Mongo.Variable<Record.Link>) in MongoExpression.expr
                        {
                            $0[.eq] = ("objectId", .expr { $0[.type] = link })
                        }
                    }
                }
            }
        }
    }

    var zones:MongoExpression
    {
        .expr
        {
            $0[.coalesce] = (self[.zones], [] as [Never])
        }
    }
}
extension Mongo.Variable<Unidoc.Scalar>
{
    /// Returns a predicate that matches all extensions to the same scope as
    /// the value of this variable, and is either from the latest version of
    /// its home package, or has an ID between the given min and max.
    func groups(min:Self, max:Self) -> Mongo.PredicateDocument
    {
        .init
        {
            $0[.expr] = .expr
            {
                $0[.and] = .init
                {
                    $0.expr
                    {
                        $0[.eq] = (Record.Group[.scope], self)
                    }
                    $0.expr
                    {
                        $0[.or] = .init
                        {
                            $0.expr
                            {
                                $0[.and] = .init
                                {
                                    $0.expr
                                    {
                                        $0[.gte] = (Record.Group[.id], min)
                                    }
                                    $0.expr
                                    {
                                        $0[.lte] = (Record.Group[.id], max)
                                    }
                                }
                            }
                            $0.expr
                            {
                                $0[.eq] = (Record.Group[.latest], true)
                            }
                        }
                    }
                }
            }
        }
    }
}
