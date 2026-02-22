import MongoDB
import MongoQL
import Unidoc
import UnidocRecords

extension Unidoc.DB.Volumes {
    struct VacuumLatest {
        let latest: Unidoc.Edition

        init(around latest: Unidoc.Edition) {
            self.latest = latest
        }
    }
}
extension Unidoc.DB.Volumes.VacuumLatest: Mongo.UpdateQuery {
    typealias Target = Unidoc.DB.Volumes
    typealias Effect = Mongo.Many

    var ordered: Bool { false }

    func build(updates: inout Mongo.UpdateListEncoder<Mongo.Many>) {
        updates {
            $0[.multi] = true
            $0[.hint] = Unidoc.DB.Volumes.indexLatestFlag.id
            $0[.q] {
                $0[.and] {
                    let cell: ClosedRange<Unidoc.Edition> = .package(self.latest.package)

                    $0 { $0[Unidoc.VolumeMetadata[.latest]] = true }
                    $0 { $0[Unidoc.VolumeMetadata[.id]] { $0[.gte] = cell.lowerBound } }
                    $0 { $0[Unidoc.VolumeMetadata[.id]] { $0[.lte] = cell.upperBound } }
                    $0 { $0[Unidoc.VolumeMetadata[.id]] { $0[.ne] = self.latest } }
                }
            }
            $0[.u] {
                $0[.unset] { $0[Unidoc.VolumeMetadata[.latest]] = true }
            }
        }
    }
}
