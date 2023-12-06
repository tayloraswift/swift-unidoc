import MongoDB
import MongoQL
import Unidoc
import UnidocRecords

extension UnidocDatabase.Volumes
{
    struct AlignRealm
    {
        let range:ClosedRange<Unidoc.Edition>
        let realm:Realm?

        init(range:ClosedRange<Unidoc.Edition>, to realm:Realm?)
        {
            self.range = range
            self.realm = realm
        }
    }
}
extension UnidocDatabase.Volumes.AlignRealm:Mongo.UpdateQuery
{
    typealias Target = UnidocDatabase.Volumes
    typealias Effect = Mongo.Many

    var ordered:Bool { false }

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
                        $0[Volume.Metadata[.id]] = .init { $0[.gte] = self.range.lowerBound }
                    }
                    $0.append
                    {
                        $0[Volume.Metadata[.id]] = .init { $0[.lte] = self.range.upperBound }
                    }
                    $0.append
                    {
                        if  let realm:Realm = self.realm
                        {
                            $0[Volume.Metadata[.realm]] = .init { $0[.ne] = realm }
                        }
                        else
                        {
                            $0[Volume.Metadata[.realm]] = .init { $0[.exists] = true }
                        }
                    }
                }
            }
            $0[.u] = .init
            {
                if  let realm:Realm = self.realm
                {
                    $0[.set] = .init
                    {
                        $0[Volume.Metadata[.realm]] = realm
                    }
                }
                else
                {
                    $0[.unset] = .init
                    {
                        $0[Volume.Metadata[.realm]] = ()
                    }
                }
            }
        }
    }
}
