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
        let master:DeepQuery.Master

        init(_ master:DeepQuery.Master)
        {
            self.master = master
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
                $0[.coalesce] = (self.master[Record.Master[array]], [] as [Never])
            }
        }

        list.append
        {
            $0.append(self.master[Record.Master[.namespace]])
            $0.append(self.master[Record.Master[.culture]])
        }

        list.expr
        {
            let constraint:Mongo.UntypedVariable = "self"

            $0[.map] = .let(constraint)
            {
                $0[.input] = .expr
                {
                    $0[.coalesce] =
                    (
                        self.master[Record.Master[.signature_generics_constraints]],
                        [] as [Never]
                    )
                }
                $0[.in] = constraint[GenericConstraint<Unidoc.Scalar?>[.nominal]]
            }
        }

        list.expr
        {
            let outline:Mongo.UntypedVariable = "self"
            $0[.map] = .let(outline)
            {
                $0[.input] = .expr
                {
                    $0[.coalesce] =
                    (
                        self.master[Record.Master[.details] / Record.Passage[.outlines]],
                        [] as [Never]
                    )
                }
                $0[.in] = outline[Record.Outline[.scalars]]
            }
        }
    }
}
