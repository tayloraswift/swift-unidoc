import BSON
import MongoQL
import UnidocRecords

extension Unidoc.LookupAdjacent {
    struct Volumes {
        let upstream: Mongo.List<Unidoc.VolumeMetadata.Dependency, Mongo.AnyKeyPath>
        let groups: Mongo.List<Unidoc.AnyGroup, Mongo.AnyKeyPath>

        init(
            upstream: Mongo.List<Unidoc.VolumeMetadata.Dependency, Mongo.AnyKeyPath>,
            groups: Mongo.List<Unidoc.AnyGroup, Mongo.AnyKeyPath>
        ) {
            self.upstream = upstream
            self.groups = groups
        }
    }
}
extension Unidoc.LookupAdjacent.Volumes {
    static func += (list: inout Mongo.SetListEncoder, self: Self) {
        list { $0[.map] = self.upstream.map { $0[.linked] } }
        list {
            $0[.reduce] = self.groups.flatMap {
                (group: Mongo.Variable<Unidoc.AnyGroup>) -> Mongo.Expression in
                .expr {
                    $0[.coalesce] = (group[.zones], [] as [Never])
                }
            }
        }
    }
}
