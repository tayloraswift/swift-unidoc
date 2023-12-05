import MongoDB
import MongoQL
import Unidoc
import UnidocRecords

extension UnidocDatabase
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
extension UnidocDatabase.Vertices
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
        $0[Volume.Vertex[.zone]] = (+)
        $0[Volume.Vertex[.stem]] = (+)
        $0[Volume.Vertex[.hash]] = (+)
    }
        where:
    {
        //  This limits the index to vertices with a stem. This is all of them,
        //  except for ``Volume.Vertex.File``.
        $0[Volume.Vertex[.stem]] = .init { $0[.exists] = true }
    }

    public static
    let indexHash:Mongo.CollectionIndex = .init("Hash",
        collation: VolumeCollation.spec,
        unique: true)
    {
        $0[Volume.Vertex[.hash]] = (+)
        $0[Volume.Vertex[.id]] = (+)
    }
}
extension UnidocDatabase.Vertices:Mongo.CollectionModel
{
    public
    typealias Element = Volume.Vertex

    @inlinable public static
    var name:Mongo.Collection { "VolumeVertices" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex] { [ Self.indexStem, Self.indexHash ] }
}
extension UnidocDatabase.Vertices:Mongo.RecodableModel
{
    public
    func recode(with session:Mongo.Session) async throws -> (modified:Int, of:Int)
    {
        try await self.recode(through: Volume.Vertex.self,
            with: session,
            by: .now.advanced(by: .seconds(60)))
    }
}
extension UnidocDatabase.Vertices
{
    @discardableResult
    func insert(_ vertices:Volume.Vertices,
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
                $0 += vertices.articles.lazy.map(Volume.Vertex.article(_:))
                $0 += vertices.cultures.lazy.map(Volume.Vertex.culture(_:))
                $0 += vertices.decls.lazy.map(Volume.Vertex.decl(_:))
                $0 += vertices.files.lazy.map(Volume.Vertex.file(_:))
                $0 += vertices.foreign.lazy.map(Volume.Vertex.foreign(_:))

                $0.append(Volume.Vertex.global(vertices.global))
            },
            against: self.database)

        return try response.insertions()
    }
}
