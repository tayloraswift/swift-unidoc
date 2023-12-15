import MongoQL
import Unidoc
import UnidocDB
import UnidocRecords

extension Unidoc.VolumeRange:Unidoc.VertexPredicate
{
    public
    func extend(pipeline:inout Mongo.PipelineEncoder, input:Mongo.KeyPath, output:Mongo.KeyPath)
    {
        pipeline[.lookup] = .init
        {
            let min:Mongo.Variable<Unidoc.Scalar> = "min"
            let max:Mongo.Variable<Unidoc.Scalar> = "max"

            $0[.from] = UnidocDatabase.Vertices.name
            $0[.let] = .init
            {
                $0[let: min] = input / Unidoc.VolumeMetadata[self.min]
                $0[let: max] = input / Unidoc.VolumeMetadata[self.max]
            }
            $0[.pipeline] = .init
            {
                $0.stage
                {
                    $0[.match] = .init
                    {
                        $0[.expr] = .expr
                        {
                            $0[.and] =
                            (
                                .expr
                                {
                                    $0[.gte] = (Unidoc.Vertex[.id], min)
                                },
                                .expr
                                {
                                    $0[.lte] = (Unidoc.Vertex[.id], max)
                                }
                            )
                        }
                    }
                }
                $0.stage
                {
                    $0[.limit] = 50
                }
            }
            $0[.as] = output
        }
    }
}