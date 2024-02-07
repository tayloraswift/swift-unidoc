import MongoDB
import MongoQL
import Unidoc
import UnidocRecords

extension Unidoc.DB.Groups
{
    struct AlignLatest
    {
        let latest:Unidoc.Edition
        let realm:Unidoc.Realm

        init(to latest:Unidoc.Edition, in realm:Unidoc.Realm)
        {
            self.latest = latest
            self.realm = realm
        }
    }
}
extension Unidoc.DB.Groups.AlignLatest:Mongo.UpdateQuery
{
    typealias Target = Unidoc.DB.Groups
    typealias Effect = Mongo.Many

    var ordered:Bool { true }

    func build(updates:inout Mongo.UpdateListEncoder<Mongo.Many>)
    {
        let latest:ClosedRange<Unidoc.Scalar> = .edition(self.latest)
        let all:ClosedRange<Unidoc.Scalar> = .package(self.latest.package)

        updates
        {
            $0[.multi] = true
            $0[.q]
            {
                $0[.and]
                {
                    $0 { $0[Unidoc.AnyGroup[.id]] { $0[.gte] = latest.lowerBound } }
                    $0 { $0[Unidoc.AnyGroup[.id]] { $0[.lte] = latest.upperBound } }
                    $0 { $0[Unidoc.AnyGroup[.realm]] { $0[.ne] = self.realm } }
                }
            }
            $0[.u]
            {
                $0[.set] { $0[Unidoc.AnyGroup[.realm]] = self.realm }
            }
        }

        updates
        {
            $0[.multi] = true
            $0[.hint] = Unidoc.DB.Groups.indexRealm.id
            $0[.q]
            {
                $0[.and]
                {
                    $0 { $0[Unidoc.AnyGroup[.id]] { $0[.gte] = all.lowerBound } }
                    $0 { $0[Unidoc.AnyGroup[.id]] { $0[.lte] = all.upperBound } }
                    $0
                    {
                        $0[.or]
                        {
                            $0 { $0[Unidoc.AnyGroup[.id]] { $0[.lt] = latest.lowerBound } }
                            $0 { $0[Unidoc.AnyGroup[.id]] { $0[.gt] = latest.upperBound } }
                        }
                    }
                    $0 { $0[Unidoc.AnyGroup[.realm]] { $0[.exists] = true } }
                }
            }
            $0[.u]
            {
                $0[.unset] { $0[Unidoc.AnyGroup[.realm]] = () }
            }
        }
    }
}
