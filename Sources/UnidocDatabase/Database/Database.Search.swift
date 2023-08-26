import MongoDB
import Unidoc
import UnidocRecords

extension Database
{
    /// A single-document collection containing a ``Record.SearchIndex``.
    @frozen public
    struct Search
    {
        public
        let database:Mongo.Database

        @inlinable public
        init(database:Mongo.Database)
        {
            self.database = database
        }
    }
}
extension Database.Search:DatabaseCollection
{
    typealias ElementID = Never?

    @inlinable public static
    var name:Mongo.Collection { "search" }
}
extension Database.Search
{
    func setup(with session:Mongo.Session) async throws
    {
    }
}
