import MongoDB
import MongoQL
import Unidoc
import UnidocRecords

extension UnidocDatabase.Groups
{
    struct AlignLatest
    {
        let latest:Unidoc.Edition
        let realm:Unidex

        init(to latest:Unidoc.Edition, in realm:Unidex)
        {
            self.latest = latest
            self.realm = realm
        }
    }
}
extension UnidocDatabase.Groups.AlignLatest:Mongo.UpdateQuery
{
    typealias Target = UnidocDatabase.Volumes
    typealias Effect = Mongo.Many

    var ordered:Bool { true }

    func build(updates:inout Mongo.UpdateEncoder<Mongo.Many>)
    {
        updates
        {
            $0[.multi] = true
            $0[.q] = .init
            {
                $0[.and] = .init
                {
                    $0.append
                    {
                        $0[Volume.Group[.id]] = .init { $0[.gte] = self.latest.min }
                    }
                    $0.append
                    {
                        $0[Volume.Group[.id]] = .init { $0[.lte] = self.latest.max }
                    }
                    $0.append
                    {
                        $0[Volume.Group[.realm]] = .init { $0[.ne] = self.realm }
                    }
                }
            }
            $0[.u] = .init
            {
                $0[.set] = .init
                {
                    $0[Volume.Group[.realm]] = self.realm
                }
            }
        }

        let cell:ClosedRange<Unidoc.Edition> = .package(self.latest.package)

        updates
        {
            $0[.multi] = true
            $0[.hint] = UnidocDatabase.Groups.indexRealm.id
            $0[.q] = .init
            {
                $0[.and] = .init
                {
                    $0.append
                    {
                        $0[Volume.Group[.id]] = .init { $0[.gte] = cell.lowerBound.min }
                    }
                    $0.append
                    {
                        $0[Volume.Group[.id]] = .init { $0[.lte] = cell.upperBound.max }
                    }
                    $0.append
                    {
                        $0[.or] = .init
                        {
                            $0.append
                            {
                                $0[Volume.Group[.id]] = .init { $0[.lt] = self.latest.min }
                            }
                            $0.append
                            {
                                $0[Volume.Group[.id]] = .init { $0[.gt] = self.latest.max }
                            }
                        }
                    }
                    $0.append
                    {
                        $0[Volume.Group[.realm]] = .init { $0[.exists] = true }
                    }
                }
            }
            $0[.u] = .init
            {
                $0[.unset] = .init
                {
                    $0[Volume.Group[.realm]] = ()
                }
            }
        }
    }
}
