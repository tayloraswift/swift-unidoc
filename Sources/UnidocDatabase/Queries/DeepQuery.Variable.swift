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
    var scalars:String { self[T[.scalars]] }
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
