import BSON
import MongoQL
import Signatures
import UnidocRecords

extension Unidoc.LookupAdjacent
{
    /// A type that binds a ``Unidoc.AnyVertex`` and knows how to extract its adjacent vertices.
    struct Vertices
    {
        private
        let layer:Unidoc.GroupLayerPredicate

        let groups:Mongo.List<Unidoc.AnyGroup, Mongo.KeyPath>
        let vertex:Mongo.KeyPath

        init(layer:Unidoc.GroupLayerPredicate,
            groups:Mongo.List<Unidoc.AnyGroup, Mongo.KeyPath>,
            vertex:Mongo.KeyPath)
        {
            self.layer = layer

            self.groups = groups
            self.vertex = vertex
        }
    }
}
extension Unidoc.LookupAdjacent.Vertices
{
    static
    func += (list:inout BSON.ListEncoder, self:Self)
    {
        //  Extract scalars adjacent to the current vertex.
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
                $0[.coalesce] = (self.vertex / Unidoc.AnyVertex[array], [] as [Never])
            }
        }

        list.append
        {
            $0.append(self.vertex / Unidoc.AnyVertex[.namespace])
            $0.append(self.vertex / Unidoc.AnyVertex[.culture])
            $0.append(self.vertex / Unidoc.AnyVertex[.extendee])
            $0.append(self.vertex / Unidoc.AnyVertex[.renamed])
            $0.append(self.vertex / Unidoc.AnyVertex[.readme])
            $0.append(self.vertex / Unidoc.AnyVertex[.file])
        }

        list.expr
        {
            let constraints:Mongo.List<GenericConstraint<Unidoc.Scalar?>, Mongo.KeyPath> =
                .init(in: self.vertex / Unidoc.AnyVertex[.signature_generics_constraints])

            $0[.map] = constraints.map { $0[.nominal] }
        }

        for passage:Unidoc.AnyVertex.CodingKey in [.overview, .details]
        {
            list.expr
            {
                let outlines:Mongo.List<Unidoc.Outline, Mongo.KeyPath> = .init(
                    in: self.vertex / Unidoc.AnyVertex[passage] / Unidoc.Passage[.outlines])

                $0[.reduce] = outlines.flatMap(\.scalars)
            }
        }

        //  Extract scalars adjacent to the list of vertex groups.
        list.expr
        {
            $0[.reduce] = self.groups.flatMap(self.layer.adjacent(to:))
        }
    }
}
