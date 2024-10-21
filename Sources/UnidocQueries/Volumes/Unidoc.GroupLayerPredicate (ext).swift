import BSON
import MongoQL
import Signatures
import Unidoc
import UnidocRecords

extension Unidoc.GroupLayerPredicate
{
    func adjacent(to group:Mongo.Variable<Unidoc.AnyGroup>) -> Mongo.Expression
    {
        self.layer?.adjacent(to: group) ?? .expr
        {
            $0[.concatArrays]
            {
                $0 { $0[+] = group[.culture] }
                $0 { $0[.map] = group.constraints.map { $0[.nominal] } }

                for key:Unidoc.AnyGroup.CodingKey
                    in [.conformances, .features, .nested, .subforms, .items]
                {
                    $0 { $0[.coalesce] = (group[key], [] as [Never]) }
                }

                for passage:Unidoc.AnyGroup.CodingKey in [.overview, .details]
                {
                    let outlines:Mongo.List<Unidoc.Outline, Mongo.AnyKeyPath> = .init(
                        in: group[passage] / Unidoc.Passage[.outlines])

                    $0 { $0[.reduce] = outlines.flatMap(\.scalars) }
                }
            }
        }
    }
}
