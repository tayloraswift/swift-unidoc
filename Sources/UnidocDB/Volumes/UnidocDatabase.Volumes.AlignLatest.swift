import MongoDB
import MongoQL
import Unidoc
import UnidocRecords

extension UnidocDatabase.Volumes
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
extension UnidocDatabase.Volumes.AlignLatest:Mongo.UpdateQuery
{
    typealias Target = UnidocDatabase.Volumes
    typealias Effect = Mongo.Many

    var ordered:Bool { false }

    func build(updates:inout Mongo.UpdateEncoder<Mongo.Many>)
    {
        //  If the metadata document for `self.latest` doesn’t have the latest-flag, add it.
        updates
        {
            $0[.multi] = false
            $0[.q] = .init
            {
                $0[Unidoc.VolumeMetadata[.id]] = self.latest
                $0[Unidoc.VolumeMetadata[.latest]] = .init { $0[.ne] = true }
            }
            $0[.u] = .init
            {
                $0[.set] = .init
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
            $0[.hint] = UnidocDatabase.Volumes.indexCoordinateLatest.id
            $0[.q] = .init
            {
                $0[.and] = .init
                {
                    let cell:ClosedRange<Unidoc.Edition> = .package(self.latest.package)

                    $0.append
                    {
                        $0[Unidoc.VolumeMetadata[.id]] = .init { $0[.gte] = cell.lowerBound }
                    }
                    $0.append
                    {
                        $0[Unidoc.VolumeMetadata[.id]] = .init { $0[.lte] = cell.upperBound }
                    }
                    $0.append
                    {
                        $0[Unidoc.VolumeMetadata[.id]] = .init { $0[.ne] = self.latest }
                        $0[Unidoc.VolumeMetadata[.latest]] = .init { $0[.exists] = true }
                    }
                }
            }
            $0[.u] = .init
            {
                $0[.unset] = .init
                {
                    $0[Unidoc.VolumeMetadata[.latest]] = ()
                }
            }
        }
    }
}
