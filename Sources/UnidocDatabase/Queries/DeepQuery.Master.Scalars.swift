import BSONEncoding
import MongoBuiltins
import MongoExpressions
import Signatures
import UnidocRecords
import Unidoc

extension DeepQuery.Master
{
    struct Scalars
    {
        let key:BSON.Key

        init(in key:BSON.Key)
        {
            self.key = key
        }
    }
}
extension DeepQuery.Master.Scalars
{
    static
    func += (list:inout BSON.ListEncoder, self:Self)
    {
        for array:Record.Master.CodingKey in
        [
            .signature_expanded_scalars,
            .superforms,
            .scope,
        ]
        {
            list.expr
            {
                $0[.coalesce] = ("$\(self.key / Record.Master[array])", [] as [Never])
            }
        }

        list.append
        {
            $0.append("$\(self.key / Record.Master[.namespace])")
            $0.append("$\(self.key / Record.Master[.culture])")
        }

        list.expr
        {
            let constraint:DeepQuery.Variable<GenericConstraint<Unidoc.Scalar?>> = "self"

            $0[.map] = .let(constraint)
            {
                $0[.input] = .expr
                {
                    $0[.coalesce] =
                    (
                        "$\(self.key / Record.Master[.signature_generics_constraints])",
                        [] as [Never]
                    )
                }
                $0[.in] = constraint.scalar
            }
        }

        for passage:Record.Master.CodingKey in [.overview, .details]
        {
            list.expr
            {
                let outlines:DeepQuery.List<Record.Outline> = .init(
                    in: self.key / Record.Master[passage] / Record.Passage[.outlines])

                $0[.reduce] = outlines.join(\.scalars)
            }
        }
    }
}
