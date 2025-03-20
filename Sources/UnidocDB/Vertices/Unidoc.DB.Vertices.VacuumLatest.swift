import MongoDB
import MongoQL
import Unidoc
import UnidocRecords

extension Unidoc.DB.Vertices
{
    struct VacuumLatest
    {
        let latest:Unidoc.Edition

        init(around latest:Unidoc.Edition)
        {
            self.latest = latest
        }
    }
}
extension Unidoc.DB.Vertices.VacuumLatest:Mongo.UpdateQuery
{
    typealias Target = Unidoc.DB.Vertices
    typealias Effect = Mongo.Many

    var ordered:Bool { true }

    func build(updates:inout Mongo.UpdateListEncoder<Mongo.Many>)
    {
        let latest:ClosedRange<Unidoc.Scalar> = .edition(self.latest)
        let all:ClosedRange<Unidoc.Scalar> = .package(self.latest.package)

        updates
        {
            $0[.multi] = true
            $0[.hint] = Unidoc.DB.Vertices.indexLinkableFlag.id
            $0[.q]
            {
                $0[.and]
                {
                    $0 { $0[Unidoc.AnyVertex[.linkable]] = true }
                    $0 { $0[Unidoc.AnyVertex[.id]] { $0[.gte] = all.lowerBound } }
                    $0 { $0[Unidoc.AnyVertex[.id]] { $0[.lte] = all.upperBound } }
                    $0
                    {
                        $0[.or]
                        {
                            $0 { $0[Unidoc.AnyVertex[.id]] { $0[.lt] = latest.lowerBound } }
                            $0 { $0[Unidoc.AnyVertex[.id]] { $0[.gt] = latest.upperBound } }
                        }
                    }
                }
            }
            $0[.u]
            {
                $0[.unset] { $0[Unidoc.AnyVertex[.linkable]] = true }
                $0[.unset] { $0[Unidoc.AnyVertex[.trunk]] = true }
            }
        }
    }
}
