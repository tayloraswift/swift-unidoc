
import MongoQL
import UnidocRecords
import UnidocSelectors

extension Selector.Zone
{
    var hint:Mongo.SortDocument
    {
        .init
        {
            $0[Record.Zone[.package]] = (+)

            if  case _? = self.version
            {
                $0[Record.Zone[.version]] = (+)
            }
            else
            {
                $0[Record.Zone[.patch]] = (-)
            }
        }
    }
}
