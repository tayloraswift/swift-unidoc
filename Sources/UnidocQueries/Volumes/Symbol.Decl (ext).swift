import FNV1
import MongoQL
import Symbols
import Unidoc
import UnidocDatabase
import UnidocRecords

extension Symbol.Decl:VolumeLookupPredicate
{
    public
    func stage(_ stage:inout Mongo.PipelineStage, input:Mongo.KeyPath, output:Mongo.KeyPath)
    {
        stage[.lookup] = .init
        {
            let min:Mongo.Variable<Unidoc.Scalar> = "min"
            let max:Mongo.Variable<Unidoc.Scalar> = "max"

            $0[.from] = Unidoc.Database.Masters.name
            $0[.let] = .init
            {
                $0[let: min] = input / Volume.Names[.planes_min]
                $0[let: max] = input / Volume.Names[.planes_max]
            }
            $0[.pipeline] = .init
            {
                $0.stage
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
                                    $0[.eq] = (Volume.Master[.hash], hash)
                                },
                                .expr
                                {
                                    $0[.gte] = (Volume.Master[.id], min)
                                },
                                .expr
                                {
                                    $0[.lte] = (Volume.Master[.id], max)
                                },
                                .expr
                                {
                                    $0[.eq] = (Volume.Master[.symbol], self)
                                }
                            )
                        }
                    }
                }
                $0.stage
                {
                    $0[.limit] = 1
                }
            }
            $0[.as] = output
        }
    }
}
