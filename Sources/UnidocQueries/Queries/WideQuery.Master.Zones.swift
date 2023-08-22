import BSONEncoding
import MongoQL
import UnidocSelectors
import UnidocRecords

extension WideQuery.Master
{
    struct Zones
    {
        let path:Mongo.KeyPath

        init(in path:Mongo.KeyPath)
        {
            self.path = path
        }
    }
}
extension WideQuery.Master.Zones
{
    static
    func += (list:inout BSON.ListEncoder, self:Self)
    {
        list.expr
        {
            $0[.coalesce] = (self.path / Record.Master[.zones], [] as [Never])
        }
        list.expr
        {
            let dependencies:Mongo.List<Record.Master.Meta.Dependency, Mongo.KeyPath> = .init(
                in: self.path / Record.Master[.dependencies])

            $0[.map] = dependencies.map { $0[.resolution] }
        }
    }
}
