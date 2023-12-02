import BSON
import BSON
import MongoDB
import SymbolGraphs
import UnidocRecords

extension UnidocDatabase
{
    @frozen public
    struct DocsFeed
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
extension UnidocDatabase.DocsFeed:Mongo.CollectionModel
{
    public
    typealias Element = Activity<Unidoc.Edition>

    @inlinable public static
    var name:Mongo.Collection { "DocsFeed" }

    public static
    let indexes:[Mongo.CollectionIndex] =
    [
        .init("Volume",
            collation: SimpleCollation.spec,
            unique: true)
        {
            $0[Activity<Unidoc.Edition>[.volume]] = (+)
        },
    ]

    /// 1 MB ought to be enough for anybody.
    @inlinable public
    var capacity:(bytes:Int, count:Int?) { (1 << 20, 16) }
}
extension UnidocDatabase.DocsFeed
{
    public
    func push(_ activity:Activity<Unidoc.Edition>,
        with session:Mongo.Session) async throws -> Bool
    {
        let (_, inserted):(Activity<Unidoc.Edition>, BSON.Millisecond?) = try await session.run(
            command: Mongo.FindAndModify<Mongo.Upserting<
                    Activity<Unidoc.Edition>,
                    BSON.Millisecond>>.init(
                Self.name,
                returning: .new)
            {
                $0[.hint] = .init
                {
                    $0[Activity<Unidoc.Edition>[.volume]] = (+)
                }
                $0[.query] = .init
                {
                    $0[Activity<Unidoc.Edition>[.volume]] = activity.volume
                }
                $0[.update] = .init
                {
                    $0[.setOnInsert] = .init
                    {
                        $0[Activity<Unidoc.Edition>[.id]] = activity.id
                        $0[Activity<Unidoc.Edition>[.volume]] = activity.volume
                    }
                }
            },
            against: self.database)

        return inserted != nil
    }
}
