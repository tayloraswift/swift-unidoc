import MongoDB
import MongoQL
import Unidoc
import UnidocRecords

extension UnidocDatabase.Groups
{
    struct AlignLatest
    {
        let latest:Unidoc.Edition
        let realm:Realm

        init(to latest:Unidoc.Edition, in realm:Realm)
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
                        $0[Volume.Group[.latest]] = .init { $0[.ne] = true }
                    }
                }
            }
            $0[.u] = .init
            {
                $0[.set] = .init
                {
                    $0[Volume.Group[.latest]] = true
                }
            }
        }
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
        //  If any records within the same cell but not within the specified zone
        //  have the latest-flag, remove it from them.
        let cell:ClosedRange<Unidoc.Edition> = .package(self.latest.package)
        for key:Volume.Group.CodingKey in [.latest, .realm]
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
                            $0[Volume.Group[key]] = .init { $0[.exists] = true }
                        }
                    }
                }
                $0[.u] = .init
                {
                    $0[.unset] = .init
                    {
                        $0[Volume.Group[key]] = ()
                    }
                }
            }
        }
    }
}
