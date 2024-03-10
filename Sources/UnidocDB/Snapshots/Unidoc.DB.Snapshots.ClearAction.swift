import MongoDB
import MongoQL
import UnidocRecords

extension Unidoc.DB.Snapshots
{
    @frozen public
    enum ClearAction
    {
        case one(Unidoc.Edition)
    }
}
extension Unidoc.DB.Snapshots.ClearAction:Mongo.UpdateQuery
{
    public
    typealias Target = Unidoc.DB.Snapshots
    public
    typealias Effect = Mongo.One

    @inlinable public
    var ordered:Bool { false }

    public
    func build(updates:inout Mongo.UpdateListEncoder<Mongo.One>)
    {
        updates
        {
            switch self
            {
            case .one(let edition):
                $0[.q] { $0[Unidoc.Snapshot[.id]] = edition }
            }

            $0[.u]
            {
                $0[.unset]
                {
                    $0[Unidoc.Snapshot[.action]] = ()
                }
            }
        }
    }
}
