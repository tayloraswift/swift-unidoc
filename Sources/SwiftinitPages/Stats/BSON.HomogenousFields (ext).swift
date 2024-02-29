import BSON
import UnidocProfiling
import UnidocRecords

extension BSON.HomogenousFields:PieValues where Key:PieSectorKey, Value == Int
{
    public
    typealias SectorKey = Key

    public
    var sectors:[(key:Key, value:Int)] { self.ordered }
}
