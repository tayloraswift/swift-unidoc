import BSONEncoding
import MongoBuiltins
import MongoExpressions
import Signatures
import UnidocRecords

extension DeepQuery.Master
{
    struct Zones
    {
        let key:BSON.Key

        init(in key:BSON.Key)
        {
            self.key = key
        }
    }
}
extension DeepQuery.Master.Zones
{
    static
    func += (list:inout BSON.ListEncoder, self:Self)
    {
        list.expr
        {
            $0[.coalesce] = ("$\(self.key / Record.Master[.zones])", [] as [Never])
        }
    }
}
