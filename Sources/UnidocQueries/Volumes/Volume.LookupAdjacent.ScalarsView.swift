import BSON
import MongoQL
import Signatures
import Unidoc
import UnidocRecords
import UnidocSelectors

extension Volume.LookupAdjacent
{
    /// A type that binds a ``Volume.Vertex`` and knows how to extract its adjacent scalars.
    struct ScalarsView
    {
        let path:Mongo.KeyPath

        init(in path:Mongo.KeyPath)
        {
            self.path = path
        }
    }
}
extension Volume.LookupAdjacent.ScalarsView
{
    static
    func += (list:inout BSON.ListEncoder, self:Self)
    {
        for array:Volume.Vertex.CodingKey in
        [
            .signature_expanded_scalars,
            .requirements,
            .superforms,
            .scope,
        ]
        {
            list.expr
            {
                $0[.coalesce] = (self.path / Volume.Vertex[array], [] as [Never])
            }
        }

        list.append
        {
            $0.append(self.path / Volume.Vertex[.namespace])
            $0.append(self.path / Volume.Vertex[.culture])
            $0.append(self.path / Volume.Vertex[.extendee])
            $0.append(self.path / Volume.Vertex[.file])
        }

        list.expr
        {
            let constraints:Mongo.List<GenericConstraint<Unidoc.Scalar?>, Mongo.KeyPath> =
                .init(in: self.path / Volume.Vertex[.signature_generics_constraints])

            $0[.map] = constraints.map { $0[.nominal] }
        }

        for passage:Volume.Vertex.CodingKey in [.overview, .details]
        {
            list.expr
            {
                let outlines:Mongo.List<Volume.Outline, Mongo.KeyPath> = .init(
                    in: self.path / Volume.Vertex[passage] / Volume.Passage[.outlines])

                $0[.reduce] = outlines.flatMap(\.scalars)
            }
        }
    }
}
