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
                $0[.replaceWith] = .init
                {
                    if  let tag:MD5 = self.tag
                    {
                        $0[Record.NounMap[.json]] = .expr
                        {
                            $0[.cond] =
                            (
                                if: .expr { $0[.eq] = (tag, maps / Record.NounMap[.hash]) },
                                then: .expr { $0[.binarySize] = maps / Record.NounMap[.json] },
                                else: maps / Record.NounMap[.json]
                            )
                        }
                    }
                    else
                    {
                        $0[Record.NounMap[.json]] = maps / Record.NounMap[.json]
                    }

                    $0[Record.NounMap[.hash]] = maps / Record.NounMap[.hash]
                }
            }
        }
    }
}
