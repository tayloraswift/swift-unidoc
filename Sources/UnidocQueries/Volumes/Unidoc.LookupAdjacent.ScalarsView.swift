import BSON
import MongoQL
import Signatures
import Unidoc
import UnidocRecords

extension Unidoc.LookupAdjacent
{
    /// A type that binds a ``Unidoc.AnyVertex`` and knows how to extract its adjacent scalars.
    struct ScalarsView
    {
        let path:Mongo.KeyPath

        init(in path:Mongo.KeyPath)
        {
            self.path = path
        }
    }
}
extension Unidoc.LookupAdjacent.ScalarsView
{
    static
    func += (list:inout BSON.ListEncoder, self:Self)
    {
        for array:Unidoc.AnyVertex.CodingKey in
        [
            .signature_expanded_scalars,
            .requirements,
            .superforms,
            .scope,
        ]
        {
            list.expr
            {
                $0[.coalesce] = (self.path / Unidoc.AnyVertex[array], [] as [Never])
            }
        }

        list.append
        {
            $0.append(self.path / Unidoc.AnyVertex[.namespace])
            $0.append(self.path / Unidoc.AnyVertex[.culture])
            $0.append(self.path / Unidoc.AnyVertex[.extendee])
            $0.append(self.path / Unidoc.AnyVertex[.renamed])
            $0.append(self.path / Unidoc.AnyVertex[.readme])
            $0.append(self.path / Unidoc.AnyVertex[.file])
        }

        list.expr
        {
            let constraints:Mongo.List<GenericConstraint<Unidoc.Scalar?>, Mongo.KeyPath> =
                .init(in: self.path / Unidoc.AnyVertex[.signature_generics_constraints])

            $0[.map] = constraints.map { $0[.nominal] }
        }

        for passage:Unidoc.AnyVertex.CodingKey in [.overview, .details]
        {
            list.expr
            {
                let outlines:Mongo.List<Unidoc.Outline, Mongo.KeyPath> = .init(
                    in: self.path / Unidoc.AnyVertex[passage] / Unidoc.Passage[.outlines])

                $0[.reduce] = outlines.flatMap(\.scalars)
            }
        }
    }
}
