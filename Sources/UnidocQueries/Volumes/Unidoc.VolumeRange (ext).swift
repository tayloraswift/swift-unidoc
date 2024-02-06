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
        pipeline[stage: .lookup] = .init
        {
            let min:Mongo.Variable<Unidoc.Scalar> = "min"
            let max:Mongo.Variable<Unidoc.Scalar> = "max"

            $0[.from] = Unidoc.DB.Vertices.name
            $0[.let] = .init
            {
                $0[let: min] = volume / Unidoc.VolumeMetadata[self.min]
                $0[let: max] = volume / Unidoc.VolumeMetadata[self.max]
            }
            $0[.pipeline] = .init
            {
                $0[stage: .match] = .init
                {
                    $0[.expr] = .expr
                    {
                        $0[.and] =
                        (
                            .expr
                            {
                                $0[.gte] = (Unidoc.AnyVertex[.id], min)
                            },
                            .expr
                            {
                                $0[.lte] = (Unidoc.AnyVertex[.id], max)
                            }
                        )
                    }
                }
                $0[stage: .limit] = 50
                $0[stage: .unset] = unset
            }
            $0[.as] = output
        }
    }
}
