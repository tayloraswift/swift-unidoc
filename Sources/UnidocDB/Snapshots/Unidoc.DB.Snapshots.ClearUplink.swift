import MongoDB
import MongoQL
import UnidocRecords

extension Unidoc.DB.Snapshots
{
    @frozen public
    enum ClearUplink
    {
        case one(Unidoc.Edition)
    }
}
extension Unidoc.DB.Snapshots.ClearUplink:Mongo.UpdateQuery
{
    public
    typealias Target = Unidoc.DB.Snapshots
    public
    typealias Effect = Mongo.One

    @inlinable public
    var ordered:Bool { false }

    public
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
                    $0[Unidoc.Snapshot[.link]] = ()
                }
            }
        }
    }
}
