/// A database collection that can be migrated to a new schema.
import MongoDB

public
protocol RecodableCollection
{
    func recode(with session:Mongo.Session) async throws -> (modified:Int, of:Int)
}
