import MongoDB
import MongoQL
import Unidoc
import UnidocRecords

extension Unidoc.DB
{
    @frozen public
    struct Redirects
    {
        public
        let database:Mongo.Database
        public
        let session:Mongo.Session

        @inlinable
        init(database:Mongo.Database, session:Mongo.Session)
        {
            self.database = database
            self.session = session
        }
    }
}
extension Unidoc.DB.Redirects
{
    public static
    let indexPaths:Mongo.CollectionIndex = .init("Paths",
        collation: VolumeCollation.spec,
        unique: true)
    {
        $0[Element[.id] / Unidoc.Redirect[.volume]] = (+)
        $0[Element[.stem]] = (+)
        $0[Element[.hash]] = (+)
    }
}
extension Unidoc.DB.Redirects:Mongo.CollectionModel
{
    public
    typealias Element = Unidoc.RedirectVertex

    @inlinable public static
    var name:Mongo.Collection { "VolumeRedirects" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex] { [ Self.indexPaths ] }
}
extension Unidoc.DB.Redirects:Mongo.RecodableModel
{
}
extension Unidoc.DB.Redirects
{
    @discardableResult
    func deleteAll(in volume:Unidoc.Edition) async throws -> Int
    {
        try await self.deleteAll
        {
            $0[Element[.id] / Unidoc.Redirect[.volume]] = volume
        }
    }
}
