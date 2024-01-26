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

    func build(updates:inout Mongo.UpdateEncoder<Mongo.Many>)
    {
        let latest:ClosedRange<Unidoc.Scalar> = .edition(self.latest)
        let all:ClosedRange<Unidoc.Scalar> = .package(self.latest.package)

        updates
        {
            $0[.multi] = true
            $0[.q] = .init
            {
                $0[.and] = .init
                {

                    $0.append
                    {
                        $0[Unidoc.AnyGroup[.id]] = .init { $0[.gte] = latest.lowerBound }
                    }
                    $0.append
                    {
                        $0[Unidoc.AnyGroup[.id]] = .init { $0[.lte] = latest.upperBound }
                    }
                    $0.append
                    {
                        $0[Unidoc.AnyGroup[.realm]] = .init { $0[.ne] = self.realm }
                    }
                }
            }
            $0[.u] = .init
            {
                $0[.set] = .init
                {
                    $0[Unidoc.AnyGroup[.realm]] = self.realm
                }
            }
        }

        updates
        {
            $0[.multi] = true
            $0[.hint] = Unidoc.DB.Groups.indexRealm.id
            $0[.q] = .init
            {
                $0[.and] = .init
                {

                    $0.append
                    {
                        $0[Unidoc.AnyGroup[.id]] = .init { $0[.gte] = all.lowerBound }
                    }
                    $0.append
                    {
                        $0[Unidoc.AnyGroup[.id]] = .init { $0[.lte] = all.upperBound }
                    }
                    $0.append
                    {
                        $0[.or] = .init
                        {
                            $0.append
                            {
                                $0[Unidoc.AnyGroup[.id]] = .init { $0[.lt] = latest.lowerBound }
                            }
                            $0.append
                            {
                                $0[Unidoc.AnyGroup[.id]] = .init { $0[.gt] = latest.upperBound }
                            }
                        }
                    }
                    $0.append
                    {
                        $0[Unidoc.AnyGroup[.realm]] = .init { $0[.exists] = true }
                    }
                }
            }
            $0[.u] = .init
            {
                $0[.unset] = .init
                {
                    $0[Unidoc.AnyGroup[.realm]] = ()
                }
            }
        }
    }
}
