import FNV1
import MongoQL
import Unidoc
import UnidocAPI
import UnidocDB
import UnidocRecords

extension Unidoc.VertexPath: Unidoc.VertexPredicate {
    public func lookup(
        _ lookup: inout Mongo.LookupEncoder,
        volume metadata: Mongo.AnyKeyPath,
        output: Mongo.AnyKeyPath,
        fields: Unidoc.VertexProjection
    ) {
        let volume: Mongo.Variable<Unidoc.Edition> = "zone"

        lookup[.from] = Unidoc.DB.Vertices.name
        lookup[.let] {
            $0[let: volume] = metadata / Unidoc.VolumeMetadata[.id]
        }
        lookup[.pipeline] {
            $0[stage: .match] {
                //  The stem index is partial, so we need this condition here in order
                //  for MongoDB to use the index.
                $0[Unidoc.AnyVertex[.stem]] { $0[.exists] = true }

                $0[.expr] {
                    $0[.and] {
                        //  We could also use a range operator to filter on `_id`.
                        //  But that would not be as index-friendly.
                        $0 { $0[.eq] = (Unidoc.AnyVertex[.volume], volume) }
                        $0 { $0[.eq] = (Unidoc.AnyVertex[.stem], self.stem) }

                        if  let hashrange: FNV24 = self.hash {
                            $0 { $0[.gte] = (Unidoc.AnyVertex[.hash], hashrange.min) }
                            $0 { $0[.lte] = (Unidoc.AnyVertex[.hash], hashrange.max) }
                        }
                    }
                }
            }

            $0[stage: .limit] = 50
            $0[stage: .unset] = fields.unset
        }
        lookup[.as] = output
    }
}
