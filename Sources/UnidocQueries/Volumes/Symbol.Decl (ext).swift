import FNV1
import MongoQL
import Symbols
import Unidoc
import UnidocDB
import UnidocRecords

extension Symbol.Decl:Volume.VertexPredicate
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
                $0[let: min] = input / Volume.Meta[.planes_min]
                $0[let: max] = input / Volume.Meta[.planes_max]
            }
            $0[.pipeline] = .init
            {
                $0[.match] = .init
                {
                    $0[.expr] = .expr
                    {
                        let hash:FNV24.Extended = .init(hashing: "\(self)")

                        //  The first three of these clauses should be able to use
                        //  a compound index.
                        $0[.and] =
                        (
                            .expr
                            {
                                $0[.eq] = (Volume.Vertex[.hash], hash)
                            },
                            .expr
                            {
                                $0[.gte] = (Volume.Vertex[.id], min)
                            },
                            .expr
                            {
                                $0[.lte] = (Volume.Vertex[.id], max)
                            },
                            .expr
                            {
                                $0[.eq] = (Volume.Vertex[.symbol], self)
                            }
                        )
                    }
                }

                $0[.limit] = 1
            }
            $0[.as] = output
        }
    }
}
