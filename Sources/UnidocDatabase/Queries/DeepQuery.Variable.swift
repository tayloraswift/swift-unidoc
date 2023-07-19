import MongoBuiltins
import MongoExpressions
import Signatures
import Unidoc
import UnidocRecords

extension DeepQuery
{
    struct Variable<T>:MongoExpressionVariable, ExpressibleByStringLiteral
    {
        let name:String

        init(name:String)
        {
            self.name = name
        }
    }
}
extension DeepQuery.Variable<GenericConstraint<Unidoc.Scalar?>>
{
    var scalar:String { self[T[.nominal]] }
}
extension DeepQuery.Variable<Record.Outline>
{
    var scalars:MongoExpression
    {
        .expr
        {
            $0[.coalesce] = (self[T[.scalars]], [] as [Never])
        }
    }
}
extension DeepQuery.Variable<Record.Extension>
{
    var scalars:MongoExpression
    {
        .expr
        {
            $0[.concatArrays] = .init
            {
                $0.expr
                {
                    let variable:DeepQuery.Variable<GenericConstraint<Unidoc.Scalar?>> = "self"

                    $0[.map] = .let(variable)
                    {
                        $0[.input] = .expr
                        {
                            $0[.coalesce] = (self[T[.conditions]], [] as [Never])
                        }
                        $0[.in] = variable.scalar
                    }
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
                        $0[.coalesce] = (self[T[key]], [] as [Never])
                    }
                }

                $0.append([self[T[.culture]]])
            }
        }
    }

    var zones:MongoExpression
    {
        .expr
        {
            $0[.coalesce] = (self[Record.Extension[.zones]], [] as [Never])
        }
    }
}
extension DeepQuery.Variable<Unidoc.Scalar>
{
    /// Returns a predicate that matches all extensions to the same scope as
    /// the value of this variable, and is either from the latest version of
    /// its home package, or has an ID between the given min and max.
    func extensions(min:Self, max:Self) -> Mongo.PredicateDocument
    {
        .init
        {
            $0[.expr] = .expr
            {
                $0[.and] = .init
                {
                    $0.expr
                    {
                        $0[.eq] = ("$\(Record.Extension[.scope])", self)
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
                                        $0[.gte] = ("$\(Record.Extension[.id])", min)
                                    }
                                    $0.expr
                                    {
                                        $0[.lte] = ("$\(Record.Extension[.id])", max)
                                    }
                                }
                            }
                            $0.expr
                            {
                                $0[.eq] = ("$\(Record.Extension[.latest])", true)
                            }
                        }
                    }
                }
            }
        }
    }
}
