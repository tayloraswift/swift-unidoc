import MongoDB
import MongoQL
import Unidoc
import UnidocRecords

extension Unidoc.DB.Volumes
{
    struct AlignRealm
    {
        let range:ClosedRange<Unidoc.Edition>
        let realm:Unidoc.Realm?

        init(range:ClosedRange<Unidoc.Edition>, to realm:Unidoc.Realm?)
        {
            self.range = range
            self.realm = realm
        }
    }
}
extension Unidoc.DB.Volumes.AlignRealm:Mongo.UpdateQuery
{
    typealias Target = Unidoc.DB.Volumes
    typealias Effect = Mongo.Many

    var ordered:Bool { false }

    func build(updates:inout Mongo.UpdateListEncoder<Mongo.Many>)
    {
        updates
        {
            $0[.multi] = true
            $0[.q]
            {
                $0[.and]
                {
                    $0
                    {
                        $0[Unidoc.VolumeMetadata[.id]] { $0[.gte] = self.range.lowerBound }
                    }
                    $0
                    {
                        $0[Unidoc.VolumeMetadata[.id]] { $0[.lte] = self.range.upperBound }
                    }
                    $0
                    {
                        if  let realm:Unidoc.Realm = self.realm
                        {
                            $0[Unidoc.VolumeMetadata[.realm]] { $0[.ne] = realm }
                        }
                        else
                        {
                            $0[Unidoc.VolumeMetadata[.realm]] { $0[.exists] = true }
                        }
                    }
                }
            }
            $0[.u]
            {
                if  let realm:Unidoc.Realm = self.realm
                {
                    $0[.set] { $0[Unidoc.VolumeMetadata[.realm]] = realm }
                }
                else
                {
                    $0[.unset] { $0[Unidoc.VolumeMetadata[.realm]] = true }
                }
            }
        }
    }
}
