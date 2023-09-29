import BSONEncoding
import MongoQL
import UnidocSelectors
import UnidocRecords

extension WideQuery.Master
{
    @available(*, unavailable)
    struct Zones
    {
        let path:Mongo.KeyPath

        init(in path:Mongo.KeyPath)
        {
            self.path = path
        }
    }
}
@available(*, unavailable)
extension WideQuery.Master.Zones
{
    static
    func += (list:inout BSON.ListEncoder, self:Self)
    {
        list.expr
        {
            $0[.coalesce] = (self.path / Volume.Vertex[.zones], [] as [Never])
        }
        list.expr
        {
            let dependencies:Mongo.List<Volume.Meta.Dependency, Mongo.KeyPath> = .init(
                in: self.path / Volume.Vertex[.__dependencies])

            $0[.map] = dependencies.map { $0[.resolution] }
        }
    }
}
