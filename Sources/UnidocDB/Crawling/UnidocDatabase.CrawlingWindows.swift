import BSON
import MongoDB
import SymbolGraphs
import Symbols
import UnidocRecords
import UnixTime

extension UnidocDatabase
{
    @frozen public
    struct CrawlingWindows
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
extension UnidocDatabase.CrawlingWindows
{
    public static
    let indexLastCrawled:Mongo.CollectionIndex = .init("LastCrawled",
        unique: false)
    {
        $0[Unidoc.CrawlingWindow[.crawled]] = (+)
    }
}
extension UnidocDatabase.CrawlingWindows:Mongo.CollectionModel
{
    public
    typealias Element = Unidoc.CrawlingWindow

    @inlinable public static
    var name:Mongo.Collection { "CrawlingWindows" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex] { [ Self.indexLastCrawled ] }
}
extension UnidocDatabase.CrawlingWindows
{
    /// Creates crawling windows, starting from today and going back up to `days` number of
    /// days. If some of the windows already exist, they are not reinitialized.
    public
    func create(days:Int,
        with session:Mongo.Session) async throws -> Mongo.Updates<BSON.Millisecond>
    {
        let response:Mongo.UpdateResponse<BSON.Millisecond> = try await session.run(
            command: Mongo.Update<Mongo.One, Element.ID>.init(Self.name)
            {
                let today:UnixDay = .midnight(before: .now())
                for day:UnixDay in today.advanced(by: -days) ... today
                {
                    let window:Unidoc.CrawlingWindow = .init(id: BSON.Millisecond.init(day))

                    $0
                    {
                        $0[.upsert] = true
                        $0[.q] = .init { $0[Unidoc.CrawlingWindow[.id]] = window.id }
                        $0[.u] = .init { $0[.set] = window }
                    }
                }
            },
            against: self.database)

        return try response.updates()
    }

    /// Retrieves a single (arbitrarily chosen) window that has not been crawled yet.
    public
    func pull(with session:Mongo.Session) async throws -> Unidoc.CrawlingWindow?
    {
        try await session.run(
            command: Mongo.Find<Mongo.Single<Unidoc.CrawlingWindow>>.init(Self.name,
                limit: 1)
            {
                $0[.filter] = .init
                {
                    $0[Unidoc.CrawlingWindow[.crawled]] = .init { $0[.exists] = false }
                }
            },
            against: self.database)
    }

    /// Updates the state of an existing crawling window.
    @discardableResult
    public
    func push(window:Unidoc.CrawlingWindow, with session:Mongo.Session) async throws -> Bool?
    {
        try await self.update(some: window, with: session)
    }
}
