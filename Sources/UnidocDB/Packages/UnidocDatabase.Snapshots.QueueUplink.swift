import MongoDB
import MongoQL
import UnidocRecords

extension UnidocDatabase.Snapshots
{
    @frozen public
    enum QueueUplink
    {
        case all
        case one(Unidoc.Edition)
    }
}
extension UnidocDatabase.Snapshots.QueueUplink:Mongo.UpdateQuery
{
    public
    typealias Target = UnidocDatabase.Snapshots
    public
    typealias Effect = Mongo.Many

    @inlinable public
    var ordered:Bool { false }

    public
    func build(updates:inout Mongo.UpdateEncoder<Mongo.Many>)
    {
        updates
        {
            if  case .all = self
            {
                $0[.multi] = true
            }

            $0[.q] = .init
            {
                switch self
                {
                case .all:              return
                case .one(let edition): $0[Unidoc.Snapshot[.id]] = edition
                }
            }

            $0[.u] = .init
            {
                $0[.set] = .init
                {
                    $0[Unidoc.Snapshot[.uplinking]] = true
                }
            }
        }
    }
}
