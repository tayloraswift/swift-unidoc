import MongoDB
import Unidoc
import UnidocRecords

extension Database
{
    /// A single-document collection containing a ``SearchIndex``.
    @frozen public
    struct Packages
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
extension Database.Packages:DatabaseCollection
{
    typealias ElementID = Never?

    @inlinable public static
    var name:Mongo.Collection { "packages" }
}
extension Database.Packages
{
    func setup(with session:Mongo.Session) async throws
    {
    }
}
