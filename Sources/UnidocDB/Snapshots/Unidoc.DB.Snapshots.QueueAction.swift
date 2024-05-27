import MongoDB
import MongoQL
import UnidocAPI
import UnidocRecords

extension Unidoc.DB.Snapshots
{
    @frozen public
    enum QueueAction
    {
        case all
        case one(Unidoc.Edition, action:Unidoc.LinkerAction = .uplinkRefresh)
    }
}
extension Unidoc.DB.Snapshots.QueueAction
{
    private
    var action:Unidoc.LinkerAction
    {
        switch self
        {
        case .all:                  .uplinkRefresh
        case .one(_, let action):   action
        }
    }
}
extension Unidoc.DB.Snapshots.QueueAction:Mongo.UpdateQuery
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

            $0[.q]
            {
                switch self
                {
                case .one(let edition, _):
                    $0[Unidoc.Snapshot[.id]] = edition
                    fallthrough

                case .all:
                    $0[Unidoc.Snapshot[.action]] { $0[.exists] = false }
                }
            }

            $0[.u]
            {
                $0[.set]
                {
                    $0[Unidoc.Snapshot[.action]] = self.action
                }
            }
        }
    }
}
