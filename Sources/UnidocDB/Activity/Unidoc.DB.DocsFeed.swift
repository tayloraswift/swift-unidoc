import BSON
import MongoDB
import SymbolGraphs
import UnidocRecords
import UnixTime

extension Unidoc.DB
{
    @frozen public
    struct DocsFeed
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
extension Unidoc.DB.DocsFeed:Mongo.CollectionModel
{
    public
    typealias Element = Activity<Unidoc.Edition>

    @inlinable public static
    var name:Mongo.Collection { "DocsFeed" }

    public static
    let indexes:[Mongo.CollectionIndex] =
    [
        .init("Volume",
            collation: .simple,
            unique: true)
        {
            $0[Activity<Unidoc.Edition>[.volume]] = (+)
        },
    ]

    /// 1 MB ought to be enough for anybody.
    @inlinable public
    var capacity:(bytes:Int, count:Int?) { (1 << 20, 16) }
}
extension Unidoc.DB.DocsFeed
{
    public
    func push(_ activity:Activity<Unidoc.Edition>) async throws -> Bool
    {
        let (_, inserted):(Activity<Unidoc.Edition>, UnixMillisecond?) = try await session.run(
            command: Mongo.FindAndModify<Mongo.Upserting<
                    Activity<Unidoc.Edition>,
                    UnixMillisecond>>.init(
                Self.name,
                returning: .new)
            {
                $0[.hint]
                {
                    $0[Activity<Unidoc.Edition>[.volume]] = (+)
                }
                $0[.query]
                {
                    $0[Activity<Unidoc.Edition>[.volume]] = activity.volume
                }
                $0[.update]
                {
                    $0[.setOnInsert]
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
