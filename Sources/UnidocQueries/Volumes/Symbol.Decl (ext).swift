import FNV1
import MongoQL
import Symbols
import Unidoc
import UnidocDB
import UnidocRecords

extension Symbol.Decl: Unidoc.VertexPredicate {
    public func lookup(
        _ lookup: inout Mongo.LookupEncoder,
        volume: Mongo.AnyKeyPath,
        output: Mongo.AnyKeyPath,
        fields: Unidoc.VertexProjection
    ) {
        let min: Mongo.Variable<Unidoc.Scalar> = "min"
        let max: Mongo.Variable<Unidoc.Scalar> = "max"

        lookup[.from] = Unidoc.DB.Vertices.name
        lookup[.let] {
            $0[let: min] = volume / Unidoc.VolumeMetadata[.min]
            $0[let: max] = volume / Unidoc.VolumeMetadata[.max]
        }
        lookup[.pipeline] {
            $0[stage: .match] {
                $0[.expr] {
                    let hash: FNV24.Extended = .decl(self)

                    //  The first three of these clauses should be able to use
                    //  a compound index.
                    $0[.and] {
                        $0 { $0[.eq] = (Unidoc.AnyVertex[.hash], hash) }
                        $0 { $0[.gte] = (Unidoc.AnyVertex[.id], min) }
                        $0 { $0[.lte] = (Unidoc.AnyVertex[.id], max) }
                        $0 { $0[.eq] = (Unidoc.AnyVertex[.symbol], self) }
                    }
                }
            }

            $0[stage: .limit] = 1
            $0[stage: .unset] = fields.unset
        }
        lookup[.as] = output
    }
}
