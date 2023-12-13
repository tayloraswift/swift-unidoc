import BSON
import UnidocDB
import UnidocRecords

extension Unidoc
{
    public
    typealias RealmQuery = AliasResolutionQuery<
        UnidocDatabase.RealmAliases,
        UnidocDatabase.Realms>
}
