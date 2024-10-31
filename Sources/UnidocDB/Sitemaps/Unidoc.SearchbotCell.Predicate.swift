import BSON
import FNV1
import MongoQL

extension Unidoc.SearchbotCell
{
    struct Predicate
    {
        let id:Unidoc.SearchbotCell.ID
    }
}
extension Unidoc.SearchbotCell.Predicate:Mongo.PredicateEncodable
{
    func encode(to bson:inout Mongo.PredicateEncoder)
    {
        bson[Unidoc.SearchbotCell[.id] / Unidoc.SearchbotCell.ID[.volume]] = self.id.volume
        bson[Unidoc.SearchbotCell[.id] / Unidoc.SearchbotCell.ID[.stem]] = self.id.vertex.stem

        if  let hash:FNV24 = self.id.vertex.hash
        {
            bson[Unidoc.SearchbotCell[.id] / Unidoc.SearchbotCell.ID[.hash]] = hash
        }
        else
        {
            //  Important to specify this, otherwise the query will match
            //  any vertex with the same stem.
            //
            //  Unlike ``DB.Redirects``, we care about this distinction, because
            //  the grid can contain cells from other versions, and we
            bson[Unidoc.SearchbotCell[.id] / Unidoc.SearchbotCell.ID[.hash]] = BSON.Null.init()
        }
    }
}
