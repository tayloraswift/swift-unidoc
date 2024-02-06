import MongoDB
import MongoQL
import UnidocRecords

extension Unidoc.DB.Snapshots
{
    @frozen public
    enum QueueUplink
    {
        case all
        case one(Unidoc.Edition)
    }
}
extension Unidoc.DB.Snapshots.QueueUplink:Mongo.UpdateQuery
{
    public
    typealias Target = Unidoc.DB.Snapshots
    public
    typealias Effect = Mongo.Many

    @inlinable public
    var ordered:Bool { false }

    public
    func build(updates:inout Mongo.UpdateListEncoder<Mongo.Many>)
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

            $0[.u]
            {
                $0[.set]
                {
                    $0[Unidoc.Snapshot[.link]] = Unidoc.Snapshot.LinkState.refresh
                }
            }
        }
    }
}
