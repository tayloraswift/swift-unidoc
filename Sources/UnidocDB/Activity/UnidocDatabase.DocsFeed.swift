import BSON
import MongoDB
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
extension UnidocDatabase.DocsFeed:DatabaseCollection
{
    @inlinable public static
    var name:Mongo.Collection { "docs_feed" }

    typealias ElementID = BSON.Millisecond

    static
    let indexes:[Mongo.CreateIndexStatement] =
    [
        .init
        {
            $0[.collation] = SimpleCollation.spec

            //  Cannot enforce this until the older schema fall off the front page.
            // $0[.unique] = true

            $0[.name] = "volume"
            $0[.key] = .init
            {
                $0[Activity<Unidoc.Zone>[.volume]] = (+)
            }
        },
    ]
}
extension UnidocDatabase.DocsFeed:DatabaseCollectionCapped
{
    /// 1 MB ought to be enough for anybody.
    static
    var capacity:(bytes:Int, count:Int?) { (1 << 20, 16) }
}
extension UnidocDatabase.DocsFeed
{
    public
    func push(_ activity:Activity<Unidoc.Zone>, with session:Mongo.Session) async throws -> Bool
    {
        let (_, inserted):(Activity<Unidoc.Zone>, BSON.Millisecond?) = try await session.run(
            command: Mongo.FindAndModify<Mongo.Upserting<
                    Activity<Unidoc.Zone>,
                    BSON.Millisecond>>.init(
                Self.name,
                returning: .new)
            {
                $0[.hint] = .init
                {
                    $0[Activity<Unidoc.Zone>[.volume]] = (+)
                }
                $0[.query] = .init
                {
                    $0[Activity<Unidoc.Zone>[.volume]] = activity.volume
                }
                $0[.update] = .init
                {
                    $0[.setOnInsert] = .init
                    {
                        $0[Activity<Unidoc.Zone>[.id]] = activity.id
                        $0[Activity<Unidoc.Zone>[.volume]] = activity.volume
                    }
                }
            },
            against: self.database)

        return inserted != nil
    }
}
