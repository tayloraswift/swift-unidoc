import MD5
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
    public
    let tag:MD5?

    @inlinable public
    init(zone:Selector.Zone, tag:MD5?)
    {
        self.zone = zone
        self.tag = tag
    }
}
extension NounMapQuery:DatabaseQuery
{
    public
    typealias Output = SearchIndexQuery<Unidoc.Zone>.Output

    /// A noun map query begins with a zone query. But if we ever formalize a notion of
    /// string-based zone identities, we should query from ``Database.Nouns`` directly.
    @inlinable public static
    var collection:Mongo.Collection { Database.Zones.name }

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
                    $0[.foreignField] = Record.SearchIndex<Unidoc.Zone>[.id]
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

            $0 ?= self.tag.map
            {
                Stages.Elision.init(
                    field: Record.SearchIndex<Unidoc.Zone>[.json],
                    where: Record.SearchIndex<Unidoc.Zone>[.hash],
                    is: $0)
            }
        }
    }
}
