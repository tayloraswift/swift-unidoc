import MongoDB
import MongoQL
import UnidocRecords

extension UnidocDatabase.Snapshots
{
    enum QueueUplink
    {
        case all
    }
}
extension UnidocDatabase.Snapshots.QueueUplink:Mongo.UpdateQuery
{
    typealias Target = UnidocDatabase.Snapshots
    typealias Effect = Mongo.Many

    var ordered:Bool { false }

    func build(updates:inout Mongo.UpdateEncoder<Mongo.Many>)
    {
        updates
        {
            $0[.multi] = true

            switch self
            {
            case .all:
                $0[.q] = [:]
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
