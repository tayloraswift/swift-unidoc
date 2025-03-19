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
extension Unidoc.DB.Vertices
{
    public
    static let indexStem:Mongo.CollectionIndex = .init("Stem",
        collation: .casefolding,
        unique: true)
    {
        //  If a snapshot contains a hash collision, insertion will fail.
        //  Because the index is prefixed with the stem, we expect this to be
        //  extraordinarily rare.
        //  See:
        //  forums.swift.org/t/how-does-docc-mitigate-fnv-1-hash-collisions/65673
        $0[Unidoc.AnyVertex[.volume]] = (+)
        $0[Unidoc.AnyVertex[.stem]] = (+)
        $0[Unidoc.AnyVertex[.hash]] = (+)
    }
        where:
    {
        //  This limits the index to vertices with a stem. This is all of them,
        //  except for ``Unidoc.FileVertex``.
        $0[Unidoc.AnyVertex[.stem]] { $0[.exists] = true }
    }

    public
    static let indexHash:Mongo.CollectionIndex = .init("Hash",
        collation: .casefolding,
        unique: true)
    {
        $0[Unidoc.AnyVertex[.hash]] = (+)
        $0[Unidoc.AnyVertex[.id]] = (+)
    }

    public
    static let indexLinkableFlag:Mongo.CollectionIndex = .init("LinkableFlag",
        unique: true)
    {
        $0[Unidoc.AnyVertex[.linkable]] = (+)
        $0[Unidoc.AnyVertex[.id]] = (+)
    }

    public
    static let indexLinkableStem:Mongo.CollectionIndex = .init("LinkableStem",
        collation: .casefolding)
    {
        $0[Unidoc.AnyVertex[.stem]] = (+)
    }
        where:
    {
        $0[Unidoc.AnyVertex[.linkable]] = true
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
@available(*, unavailable, message: """
    Vertices contain flags set by the database, which would be lost if they were decoded and \
    re-encoded.
    """)
extension Unidoc.DB.Vertices:Mongo.RecodableModel
{
}
extension Unidoc.DB.Vertices
{
    @discardableResult
    func insert(_ vertices:Unidoc.Mesh.Vertices, latest:Bool) async throws -> Mongo.Insertions
    {
        let response:Mongo.InsertResponse = try await session.run(
            command: Mongo.Insert.init(Self.name,
                writeConcern: .majority)
            {
                $0[.ordered] = false
            }
                documents:
            {
                for article:Unidoc.ArticleVertex in vertices.articles
                {
                    $0[Unidoc.AnyVertex.CodingKey.self]
                    {
                        Unidoc.AnyVertex.article(article).encode(to: &$0)

                        $0[.linkable] = latest ? latest : nil
                    }
                }

                $0 += vertices.cultures.lazy.map(Unidoc.AnyVertex.culture(_:))
                $0 += vertices.decls.lazy.map(Unidoc.AnyVertex.decl(_:))
                $0 += vertices.files.lazy.map(Unidoc.AnyVertex.file(_:))
                $0 += vertices.products.lazy.map(Unidoc.AnyVertex.product(_:))
                $0 += vertices.foreign.lazy.map(Unidoc.AnyVertex.foreign(_:))

                $0.append(Unidoc.AnyVertex.landing(vertices.landing))
            },
            against: self.database,
            by: .now.advanced(by: .seconds(30)))

        return try response.insertions()
    }
}
