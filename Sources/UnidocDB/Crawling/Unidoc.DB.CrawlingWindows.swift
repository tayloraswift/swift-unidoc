import BSON
import MongoDB
import UnidocRecords
import UnixTime

extension Unidoc.DB
{
    @frozen public
    struct CrawlingWindows
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
extension Unidoc.DB.CrawlingWindows
{
    public static
    let indexExpiration:Mongo.CollectionIndex = .init("LastCrawled",
        unique: false)
    {
        $0[Unidoc.CrawlingWindow[.expires]] = (+)
    }
}
extension Unidoc.DB.CrawlingWindows:Mongo.CollectionModel
{
    public
    typealias Element = Unidoc.CrawlingWindow

    @inlinable public static
    var name:Mongo.Collection { "CrawlingWindows" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex] { [ Self.indexExpiration ] }
}
extension Unidoc.DB.CrawlingWindows
{
    /// Creates crawling windows, starting from today and going back up to `days` number of
    /// days. If some of the windows already exist, they are not reinitialized.
    public
    func create(previous days:Days) async throws -> Mongo.Updates<UnixMillisecond>
    {
        let response:Mongo.UpdateResponse<UnixMillisecond> = try await session.run(
            command: Mongo.Update<Mongo.One, Element.ID>.init(Self.name)
            {
                let today:UnixDate = .today()
                for day:UnixDate in today.regressed(by: days) ... today
                {
                    let id:UnixMillisecond = .init(day)

                    $0
                    {
                        $0[.upsert] = true
                        $0[.q] { $0[Unidoc.CrawlingWindow[.id]] = id }
                        $0[.u]
                        {
                            $0[.set]
                            {
                                $0[Unidoc.CrawlingWindow[.id]] = id
                            }
                            $0[.setOnInsert]
                            {
                                $0[Unidoc.CrawlingWindow[.expires]] = UnixMillisecond.zero
                            }
                        }
                    }
                }
            },
            against: self.database)

        return try response.updates()
    }

    /// Retrieves a single window that has not been crawled yet. Windows with lower expirations
    /// will be returned first.
    public
    func pull() async throws -> Unidoc.CrawlingWindow?
    {
        let command:Mongo.Find<Mongo.Single<Unidoc.CrawlingWindow>> = .init(Self.name,
            limit: 1)
        {
            $0[.sort] { $0[Unidoc.CrawlingWindow[.expires]] = (+) }
            $0[.hint] = Self.indexExpiration.id
        }

        return try await session.run(command: command, against: self.database)
    }

    /// Updates the state of an existing crawling window.
    @discardableResult
    public
    func push(window:Unidoc.CrawlingWindow) async throws -> Bool?
    {
        try await self.update(some: window)
    }
}
