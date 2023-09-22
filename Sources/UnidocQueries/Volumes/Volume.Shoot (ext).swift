import FNV1
import MongoQL
import Unidoc
import UnidocDB
import UnidocRecords

extension Volume.Shoot:VolumeLookupPredicate
{
    public
    func stage(_ stage:inout Mongo.PipelineStage, input:Mongo.KeyPath, output:Mongo.KeyPath)
    {
        stage[.lookup] = .init
        {
            let zone:Mongo.Variable<Unidoc.Scalar> = "zone"

            $0[.from] = UnidocDatabase.Vertices.name
            $0[.let] = .init
            {
                $0[let: zone] = input / Volume.Names[.id]
            }
            $0[.pipeline] = .init
            {
                $0.stage
                {
                    $0[.match] = .init
                    {
                        //  The stem index is partial, so we need this condition here in order
                        //  for MongoDB to use the index.
                        $0[Volume.Vertex[.stem]] = .init { $0[.exists] = true }

                        $0[.expr] = .expr
                        {
                            $0[.and] = .init
                            {
                                //  We could also use a range operator to filter on `_id`.
                                //  But that would not be as index-friendly.
                                $0.expr
                                {
                                    $0[.eq] = (Volume.Vertex[.zone], zone)
                                }
                                $0.expr
                                {
                                    $0[.eq] = (Volume.Vertex[.stem], self.stem)
                                }

                                if  let hashrange:FNV24 = self.hash
                                {
                                    $0.expr
                                    {
                                        $0[.gte] = (Volume.Vertex[.hash], hashrange.min)
                                    }
                                    $0.expr
                                    {
                                        $0[.lte] = (Volume.Vertex[.hash], hashrange.max)
                                    }
                                }
                            }
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
