import MongoDB
import MongoQL
import Unidoc
import UnidocSelectors
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
extension UnidocDatabase.Vertices:DatabaseCollection
{
    @inlinable public static
    var name:Mongo.Collection { "vertices" }

    typealias ElementID = Unidoc.Scalar

    static
    let indexes:[Mongo.CreateIndexStatement] =
    [
        //  If a snapshot contains a hash collision, insertion will fail.
        //  Because the index is prefixed with the stem, we expect this to be
        //  extraordinarily rare.
        //  See:
        //  forums.swift.org/t/how-does-docc-mitigate-fnv-1-hash-collisions/65673
        .init
        {
            $0[.unique] = true
            $0[.name] = "zone,stem,hash"

            $0[.collation] = UnidocDatabase.collation
            $0[.key] = .init
            {
                $0[Volume.Vertex[.zone]] = (+)
                $0[Volume.Vertex[.stem]] = (+)
                $0[Volume.Vertex[.hash]] = (+)
            }
            //  This limits the index to masters with a stem. This is all of them,
            //  except for ``Volume.Vertex.File``.
            $0[.partialFilterExpression] = .init
            {
                $0[Volume.Vertex[.stem]] = .init { $0[.exists] = true }
            }
        },
        .init
        {
            $0[.unique] = true
            $0[.name] = "hash,id"

            $0[.collation] = UnidocDatabase.collation
            $0[.key] = .init
            {
                $0[Volume.Vertex[.hash]] = (+)
                $0[Volume.Vertex[.id]] = (+)
            }
        },
    ]
}
extension UnidocDatabase.Vertices
{
    public
    func recode(with session:Mongo.Session) async throws -> (modified:Int, of:Int)
    {
        try await self.recode(through: Volume.Vertex.self,
            with: session,
            by: .now.advanced(by: .seconds(60)))
    }
}
