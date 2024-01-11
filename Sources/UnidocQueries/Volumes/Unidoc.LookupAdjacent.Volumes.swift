import BSON
import MongoQL
import UnidocRecords

extension Unidoc.LookupAdjacent
{
    struct Volumes
    {
        let upstream:Mongo.List<Unidoc.VolumeMetadata.Dependency, Mongo.KeyPath>
        let groups:Mongo.List<Unidoc.AnyGroup, Mongo.KeyPath>

        init(
            upstream:Mongo.List<Unidoc.VolumeMetadata.Dependency, Mongo.KeyPath>,
            groups:Mongo.List<Unidoc.AnyGroup, Mongo.KeyPath>)
        {
            self.upstream = upstream
            self.groups = groups
        }
    }
}
extension Unidoc.LookupAdjacent.Volumes
{
    static
    func += (list:inout BSON.ListEncoder, self:Self)
    {
        list.expr { $0[.map] = self.upstream.map { $0[.pinned] } }
        list.expr
        {
            $0[.reduce] = self.groups.flatMap
            {
                (group:Mongo.Variable<Unidoc.AnyGroup>) -> Mongo.Expression in
                .expr
                {
                    $0[.coalesce] = (group[.zones], [] as [Never])
                }
            }
        }
    }
}
