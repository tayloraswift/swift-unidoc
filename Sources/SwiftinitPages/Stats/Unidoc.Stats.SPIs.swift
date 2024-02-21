import BSON
import OrderedCollections
import UnidocProfiling

extension Unidoc.Stats
{
    struct SPIs:PieValues
    {
        let sectors:[(key:SectorKey, value:Int)]

        private
        init(sectors:[(key:SectorKey, value:Int)])
        {
            self.sectors = sectors
        }
    }
}
extension Unidoc.Stats.SPIs
{
    init(interfaces:OrderedDictionary<BSON.Key, Int>)
    {
        var sectors:[(key:SectorKey, value:Int)]

        sectors = interfaces.map
        {
            (.init(key: $0.key), $0.value)
        }
        sectors.sort
        {
            $0.key.id < $1.key.id
        }

        self.init(sectors: sectors)
    }
}
