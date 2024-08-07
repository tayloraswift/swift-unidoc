import FNV1
import MongoQL
import Unidoc
import UnidocAPI
import UnidocDB
import UnidocRecords

extension Unidoc.Shoot:Unidoc.VertexPredicate
{
    public
    func extend(pipeline:inout Mongo.PipelineEncoder,
        volume:Mongo.AnyKeyPath,
        output:Mongo.AnyKeyPath,
        unset:[Mongo.AnyKeyPath])
    {
        pipeline[stage: .lookup]
        {
            let zone:Mongo.Variable<Unidoc.Edition> = "zone"

            $0[.from] = Unidoc.DB.Vertices.name
            $0[.let]
            {
                $0[let: zone] = volume / Unidoc.VolumeMetadata[.id]
            }
            $0[.pipeline]
            {
                $0[stage: .match]
                {
                    //  The stem index is partial, so we need this condition here in order
                    //  for MongoDB to use the index.
                    $0[Unidoc.AnyVertex[.stem]] { $0[.exists] = true }

                    $0[.expr]
                    {
                        $0[.and]
                        {
                            //  We could also use a range operator to filter on `_id`.
                            //  But that would not be as index-friendly.
                            $0.expr
                            {
                                $0[.eq] = (Unidoc.AnyVertex[.zone], zone)
                            }
                            $0.expr
                            {
                                $0[.eq] = (Unidoc.AnyVertex[.stem], self.stem)
                            }

                            if  let hashrange:FNV24 = self.hash
                            {
                                $0.expr
                                {
                                    $0[.gte] = (Unidoc.AnyVertex[.hash], hashrange.min)
                                }
                                $0.expr
                                {
                                    $0[.lte] = (Unidoc.AnyVertex[.hash], hashrange.max)
                                }
                            }
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
