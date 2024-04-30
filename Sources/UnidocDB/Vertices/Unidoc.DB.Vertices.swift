import MongoDB
import MongoQL
import Unidoc
import UnidocRecords

extension Unidoc.DB
{
    @frozen public
    struct Vertices
    {
        public
        let database:Mongo.Database

        @inlinable internal
        init(database:Mongo.Database)
        {
            self.database = database
        }
    }
}
extension Unidoc.DB.Vertices
{
    public static
    let indexStem:Mongo.CollectionIndex = .init("Stem",
        collation: VolumeCollation.spec,
        unique: true)
    {
        //  If a snapshot contains a hash collision, insertion will fail.
        //  Because the index is prefixed with the stem, we expect this to be
        //  extraordinarily rare.
        //  See:
        //  forums.swift.org/t/how-does-docc-mitigate-fnv-1-hash-collisions/65673
        $0[Unidoc.AnyVertex[.zone]] = (+)
        $0[Unidoc.AnyVertex[.stem]] = (+)
        $0[Unidoc.AnyVertex[.hash]] = (+)
    }
        where:
    {
        //  This limits the index to vertices with a stem. This is all of them,
        //  except for ``Unidoc.FileVertex``.
        $0[Unidoc.AnyVertex[.stem]] { $0[.exists] = true }
    }

    public static
    let indexHash:Mongo.CollectionIndex = .init("Hash",
        collation: VolumeCollation.spec,
        unique: true)
    {
        $0[Unidoc.AnyVertex[.hash]] = (+)
        $0[Unidoc.AnyVertex[.id]] = (+)
    }
}
extension Unidoc.DB.Vertices:Mongo.CollectionModel
{
    public
    typealias Element = Unidoc.AnyVertex

    @inlinable public static
    var name:Mongo.Collection { "VolumeVertices" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex] { [ Self.indexStem, Self.indexHash ] }
}
extension Unidoc.DB.Vertices:Mongo.RecodableModel
{
    public
    func recode(with session:Mongo.Session) async throws -> (modified:Int, of:Int)
    {
        try await self.recode(through: Unidoc.AnyVertex.self,
            with: session,
            by: .now.advanced(by: .seconds(60)))
    }
}
extension Unidoc.DB.Vertices
{
    @discardableResult
    func insert(_ vertices:Unidoc.Volume.Vertices,
        with session:Mongo.Session) async throws -> Mongo.Insertions
    {
        let response:Mongo.InsertResponse = try await session.run(
            command: Mongo.Insert.init(Self.name,
                writeConcern: .majority)
            {
                $0[.ordered] = false
            }
                documents:
            {
                $0 += vertices.articles.lazy.map(Unidoc.AnyVertex.article(_:))
                $0 += vertices.cultures.lazy.map(Unidoc.AnyVertex.culture(_:))
                $0 += vertices.decls.lazy.map(Unidoc.AnyVertex.decl(_:))
                $0 += vertices.files.lazy.map(Unidoc.AnyVertex.file(_:))
                $0 += vertices.products.lazy.map(Unidoc.AnyVertex.product(_:))
                $0 += vertices.foreign.lazy.map(Unidoc.AnyVertex.foreign(_:))

                $0.append(Unidoc.AnyVertex.landing(vertices.landing))
            },
            against: self.database)

        return try response.insertions()
    }
}
