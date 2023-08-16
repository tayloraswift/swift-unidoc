import MongoQL
import Unidoc
import UnidocAnalysis
import UnidocDatabase
import UnidocRecords
import UnidocSelectors

@frozen public
struct NounMapQuery:Equatable, Hashable, Sendable
{
    public
    let zone:Selector.Zone

    @inlinable public
    init(in zone:Selector.Zone)
    {
        self.zone = zone
    }
}
extension NounMapQuery:DatabaseQuery
{
    public
    typealias Output = Record.NounMap

    public
    var hint:Mongo.SortDocument { self.zone.hint }

    public
    var pipeline:Mongo.Pipeline
    {
        .init
        {
            let zone:Mongo.KeyPath = "zone"
            let maps:Mongo.KeyPath = "maps"

            $0 += Stages.Zone<Selector.Zone>.init(self.zone,
                as: zone)

            $0.stage
            {
                $0[.lookup] = .init
                {
                    $0[.from] = Database.Nouns.name
                    $0[.localField] = zone / Record.Zone[.id]
                    $0[.foreignField] = Record.NounMap[.id]
                    $0[.as] = maps
                }
            }
            $0.stage
            {
                $0[.unwind] = maps
            }
            $0.stage
            {
                $0[.replaceWith] = maps
            }
        }
    }
}
