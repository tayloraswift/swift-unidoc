import MongoQL
import Unidoc
import UnidocDatabase
import UnidocRecords
import UnidocSelectors

@frozen public
struct ThinQuery<LookupMode>:Equatable, Hashable, Sendable
    where LookupMode:DatabaseLookupSelector
{
    public
    let mode:LookupMode
    public
    let zone:Selector.Zone

    @inlinable public
    init(for mode:LookupMode, in zone:Selector.Zone)
    {
        self.mode = mode
        self.zone = zone
    }
}
extension ThinQuery:DatabaseQuery
{
    @inlinable public static
    var collection:Mongo.Collection { Database.Zones.name }

    public
    var hint:Mongo.SortDocument { self.zone.hint }

    public
    var pipeline:Mongo.Pipeline
    {
        .init
        {
            $0 += Stages.Zone<Selector.Zone>.init(self.zone,
                as: Output[.zone])

            $0.stage
            {
                $0[.lookup] = self.mode.lookup(
                    input: Output[.zone],
                    as: Output[.masters])
            }
        }
    }
}
