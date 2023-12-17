import MongoDB
import MongoQL
import UnidocRecords

extension UnidocDatabase.Snapshots
{
    enum ClearUplink
    {
        case one(Unidoc.Edition)
    }
}
extension UnidocDatabase.Snapshots.ClearUplink:Mongo.UpdateQuery
{
    typealias Target = UnidocDatabase.Snapshots
    typealias Effect = Mongo.One

    var ordered:Bool { false }

    func build(updates:inout Mongo.UpdateEncoder<Mongo.One>)
    {
        updates
        {

            switch self
            {
            case .one(let edition):
                $0[.q] = .init { $0[Unidoc.Snapshot[.id]] = edition }
            }

            $0[.u] = .init
            {
                $0[.unset] = .init
                {
                    $0[Unidoc.Snapshot[.uplinking]] = ()
                }
            }
        }
    }
}
