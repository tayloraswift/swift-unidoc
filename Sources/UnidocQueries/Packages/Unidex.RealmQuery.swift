import BSON
import UnidocDB
import UnidocRecords

extension Unidex
{
    public
    typealias RealmQuery = AliasResolutionQuery<
        UnidocDatabase.RealmAliases,
        UnidocDatabase.Realms>
}
