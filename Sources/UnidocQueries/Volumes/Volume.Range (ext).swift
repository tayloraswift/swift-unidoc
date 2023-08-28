import MongoQL
import Unidoc
import UnidocDatabase
import UnidocSelectors
import UnidocRecords

extension Volume.Range:VolumeLookupPredicate
{
    public
    func stage(_ stage:inout Mongo.PipelineStage, input:Mongo.KeyPath, output:Mongo.KeyPath)
    {
        stage[.lookup] = .init
        {
            let min:Mongo.Variable<Unidoc.Scalar> = "min"
            let max:Mongo.Variable<Unidoc.Scalar> = "max"

            $0[.from] = Database.Masters.name
            $0[.let] = .init
            {
                $0[let: min] = input / Volume.Names[self.min]
                $0[let: max] = input / Volume.Names[self.max]
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
                                    $0[.gte] = (Volume.Master[.id], min)
                                },
                                .expr
                                {
                                    $0[.lte] = (Volume.Master[.id], max)
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
