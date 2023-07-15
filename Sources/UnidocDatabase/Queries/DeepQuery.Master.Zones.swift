import BSONEncoding
import MongoBuiltins
import MongoExpressions
import Signatures
import UnidocRecords

extension DeepQuery.Master
{
    struct Zones
    {
        let master:DeepQuery.Master

        init(_ master:DeepQuery.Master)
        {
            self.master = master
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
            $0[.coalesce] = (self.master[Record.Master[.zones]], [] as [Never])
        }
    }
}
