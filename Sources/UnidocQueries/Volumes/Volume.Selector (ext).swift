
import MongoQL
import UnidocRecords
import UnidocSelectors

extension Volume.Selector
{
    var hint:Mongo.SortDocument
    {
        .init
        {
            $0[Volume.Names[.package]] = (+)

            if  case _? = self.version
            {
                $0[Volume.Names[.version]] = (+)
            }
            else
            {
                $0[Volume.Names[.patch]] = (-)
            }
        }
    }
}
