import FNV1
import MongoQL
import Symbols
import Unidoc
import UnidocDB
import UnidocRecords

extension Symbol.Decl:Unidoc.VertexPredicate
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
                $0[let: min] = volume / Unidoc.VolumeMetadata[.min]
                $0[let: max] = volume / Unidoc.VolumeMetadata[.max]
            }
            $0[.pipeline] = .init
            {
                $0[stage: .match]
                {
                    $0[.expr]
                    {
                        let hash:FNV24.Extended = .decl(self)

                        //  The first three of these clauses should be able to use
                        //  a compound index.
                        $0[.and]
                        {
                            $0.expr { $0[.eq] = (Unidoc.AnyVertex[.hash], hash) }
                            $0.expr { $0[.gte] = (Unidoc.AnyVertex[.id], min) }
                            $0.expr { $0[.lte] = (Unidoc.AnyVertex[.id], max) }
                            $0.expr { $0[.eq] = (Unidoc.AnyVertex[.symbol], self) }
                        }
                    }
                }

                $0[stage: .limit] = 1
                $0[stage: .unset] = unset
            }
            $0[.as] = output
        }
    }
}
