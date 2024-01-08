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
        volume:Mongo.KeyPath,
        output:Mongo.KeyPath,
        unset:[Mongo.KeyPath])
    {
        pipeline[.lookup] = .init
        {
            let zone:Mongo.Variable<Unidoc.Edition> = "zone"

            $0[.from] = UnidocDatabase.Vertices.name
            $0[.let] = .init
            {
                $0[let: zone] = volume / Unidoc.VolumeMetadata[.id]
            }
            $0[.pipeline] = .init
            {
                $0[.match] = .init
                {
                    //  The stem index is partial, so we need this condition here in order
                    //  for MongoDB to use the index.
                    $0[Unidoc.AnyVertex[.stem]] = .init { $0[.exists] = true }

                    $0[.expr] = .expr
                    {
                        $0[.and] = .init
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

                $0[.limit] = 50
                $0[.unset] = unset
            }
            $0[.as] = output
        }
    }
}
