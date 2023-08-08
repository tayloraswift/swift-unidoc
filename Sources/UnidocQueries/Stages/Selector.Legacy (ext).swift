import MongoQL
import Unidoc
import UnidocDatabase
import UnidocSelectors
import UnidocRecords

extension Selector.Decl:DatabaseLookupSelector
{
    public
    func lookup(input:Mongo.KeyPath, as output:Mongo.KeyPath) -> Mongo.LookupDocument
    {
        fatalError("unimplemented")
    }
}
