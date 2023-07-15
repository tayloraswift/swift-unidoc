import BSONEncoding
import MongoBuiltins
import MongoExpressions
import UnidocRecords

extension DeepQuery.ExtensionList
{
    struct Zones
    {
        let extensions:DeepQuery.ExtensionList

        init(_ extensions:DeepQuery.ExtensionList)
        {
            self.extensions = extensions
        }
    }
}
extension DeepQuery.ExtensionList.Zones
{
    static
    func += (list:inout BSON.ListEncoder, self:Self)
    {
        list.expr
        {
            $0[.reduce] = self.extensions.join
            {
                (current:DeepQuery.ExtensionList.LoopVariable) -> MongoExpression in .expr
                {
                    $0[.coalesce] = (current[Record.Extension[.zones]], [] as [Never])
                }
            }
        }
    }
}
