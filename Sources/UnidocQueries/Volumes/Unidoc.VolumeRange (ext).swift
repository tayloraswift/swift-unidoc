import MongoQL
import Unidoc
import UnidocDB
import UnidocRecords

extension Unidoc.VolumeRange:Unidoc.VertexPredicate
{
    public
    func extend(pipeline:inout Mongo.PipelineEncoder,
        volume:Mongo.AnyKeyPath,
        output:Mongo.AnyKeyPath,
        unset:[Mongo.AnyKeyPath])
    {
        pipeline[stage: .lookup]
        {
            let min:Mongo.Variable<Unidoc.Scalar> = "min"
            let max:Mongo.Variable<Unidoc.Scalar> = "max"

            $0[.from] = Unidoc.DB.Vertices.name
            $0[.let]
            {
                $0[let: min] = volume / Unidoc.VolumeMetadata[self.min]
                $0[let: max] = volume / Unidoc.VolumeMetadata[self.max]
            }
            $0[.pipeline]
            {
                $0[stage: .match]
                {
                    $0[.expr]
                    {
                        $0[.and]
                        {
                            $0.expr { $0[.gte] = (Unidoc.AnyVertex[.id], min) }
                            $0.expr { $0[.lte] = (Unidoc.AnyVertex[.id], max) }
                        }
                    }
                }
                $0[stage: .limit] = 50
                $0[stage: .unset] = unset
            }
            $0[.as] = output
        }
    }
}
