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
        let layer:Unidoc.GroupLayer?

        let groups:Mongo.List<Unidoc.AnyGroup, Mongo.AnyKeyPath>
        let vertex:Mongo.AnyKeyPath

        init(layer:Unidoc.GroupLayer?,
            groups:Mongo.List<Unidoc.AnyGroup, Mongo.AnyKeyPath>,
            vertex:Mongo.AnyKeyPath)
        {
            self.layer = layer

            self.groups = groups
            self.vertex = vertex
        }
    }
}
extension Unidoc.LookupAdjacent.Vertices
{
    private
    var predicate:Unidoc.GroupLayerPredicate { .init(self.layer) }
}
extension Unidoc.LookupAdjacent.Vertices
{
    static
    func += (list:inout BSON.ListEncoder, self:Self)
    {
        //  Extract scalars adjacent to the list of vertex groups.
        list.expr
        {
            $0[.reduce] = self.groups.flatMap(self.predicate.adjacent(to:))
        }

        //  Extract scalars adjacent to the current vertex.
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
            let constraints:Mongo.List<GenericConstraint<Unidoc.Scalar?>, Mongo.AnyKeyPath> =
                .init(in: self.vertex / Unidoc.AnyVertex[.signature_generics_constraints])

            $0[.map] = constraints.map { $0[.nominal] }
        }

        let arrays:[Unidoc.AnyVertex.CodingKey]
        defer
        {
            for array:Unidoc.AnyVertex.CodingKey in arrays
            {
                list.expr
                {
                    $0[.coalesce] = (self.vertex / Unidoc.AnyVertex[array], [] as [Never])
                }
            }
        }

        switch self.layer
        {
        case nil:
            arrays = [.signature_expanded_scalars, .scope, .constituents, .superforms]

        case .protocols?:
            arrays = [.signature_expanded_scalars, .scope]
            return
        }

        //  Only needed for the default layer.
        for passage:Unidoc.AnyVertex.CodingKey in [.overview, .details]
        {
            list.expr
            {
                let outlines:Mongo.List<Unidoc.Outline, Mongo.AnyKeyPath> = .init(
                    in: self.vertex / Unidoc.AnyVertex[passage] / Unidoc.Passage[.outlines])

                $0[.reduce] = outlines.flatMap(\.scalars)
            }
        }
    }
}
