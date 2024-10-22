import MongoQL
import Unidoc
import UnidocDB
import UnidocRecords

extension Unidoc.VolumeRange:Unidoc.VertexPredicate
{
    public
    func lookup(_ lookup:inout Mongo.LookupEncoder,
        volume:Mongo.AnyKeyPath,
        output:Mongo.AnyKeyPath,
        fields:Unidoc.VertexProjection)
    {
        let min:Mongo.Variable<Unidoc.Scalar> = "min"
        let max:Mongo.Variable<Unidoc.Scalar> = "max"

        lookup[.from] = Unidoc.DB.Vertices.name
        lookup[.let]
        {
            $0[let: min] = volume / Unidoc.VolumeMetadata[self.min]
            $0[let: max] = volume / Unidoc.VolumeMetadata[self.max]
        }
        lookup[.pipeline]
        {
            $0[stage: .match]
            {
                $0[.expr]
                {
                    $0[.and]
                    {
                        $0 { $0[.gte] = (Unidoc.AnyVertex[.id], min) }
                        $0 { $0[.lte] = (Unidoc.AnyVertex[.id], max) }
                    }
                }
            }
            $0[stage: .limit] = 50
            $0[stage: .unset] = fields.unset
        }
        lookup[.as] = output
    }
}
