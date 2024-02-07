import MongoDB
import MongoQL
import Unidoc
import UnidocRecords

extension Unidoc.DB.Volumes
{
    struct AlignLatest
    {
        let latest:Unidoc.Edition

        init(to latest:Unidoc.Edition)
        {
            self.latest = latest
        }
    }
}
extension Unidoc.DB.Volumes.AlignLatest:Mongo.UpdateQuery
{
    typealias Target = Unidoc.DB.Volumes
    typealias Effect = Mongo.Many

    var ordered:Bool { false }

    func build(updates:inout Mongo.UpdateListEncoder<Mongo.Many>)
    {
        //  If the metadata document for `self.latest` doesn’t have the latest-flag, add it.
        updates
        {
            $0[.multi] = false
            $0[.q]
            {
                $0[Unidoc.VolumeMetadata[.id]] = self.latest
                $0[Unidoc.VolumeMetadata[.latest]] { $0[.ne] = true }
            }
            $0[.u]
            {
                $0[.set]
                {
                    $0[Unidoc.VolumeMetadata[.latest]] = true
                }
            }
        }
        //  If any metadata documents within the same cell besides the one for `self.latest`
        //  have the latest-flag, remove it from them.
        updates
        {
            $0[.multi] = true
            $0[.hint] = Unidoc.DB.Volumes.indexCoordinateLatest.id
            $0[.q]
            {
                $0[.and]
                {
                    let cell:ClosedRange<Unidoc.Edition> = .package(self.latest.package)

                    $0
                    {
                        $0[Unidoc.VolumeMetadata[.id]] { $0[.gte] = cell.lowerBound }
                    }
                    $0
                    {
                        $0[Unidoc.VolumeMetadata[.id]] { $0[.lte] = cell.upperBound }
                    }
                    $0
                    {
                        $0[Unidoc.VolumeMetadata[.id]] { $0[.ne] = self.latest }
                        $0[Unidoc.VolumeMetadata[.latest]] { $0[.exists] = true }
                    }
                }
            }
            $0[.u]
            {
                $0[.unset] { $0[Unidoc.VolumeMetadata[.latest]] = () }
            }
        }
    }
}
