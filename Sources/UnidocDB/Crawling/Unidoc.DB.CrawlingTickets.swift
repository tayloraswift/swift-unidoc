import BSON
import MongoDB
import UnidocRecords
import UnixTime

extension Unidoc.DB
{
    @frozen public
    struct CrawlingTickets
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
extension Unidoc.DB.CrawlingTickets
{
    public static
    let indexTime:Mongo.CollectionIndex = .init("Time",
        unique: false)
    {
        $0[Unidoc.CrawlingTicket<Unidoc.Package>[.time]] = (+)
    }
}
extension Unidoc.DB.CrawlingTickets:Mongo.CollectionModel
{
    public
    typealias Element = Unidoc.CrawlingTicket<Unidoc.Package>

    @inlinable public static
    var name:Mongo.Collection { "CrawlingTickets" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex] { [ Self.indexTime ] }
}
extension Unidoc.DB.CrawlingTickets
{
    /// Creates tickets that do not exist yet, or updates the state of existing tickets. This
    /// won’t overwrite the scheduled times in existing tickets.
    public
    func create(tickets:[Element]) async throws -> Mongo.Updates<Unidoc.Package>
    {
        let response:Mongo.UpdateResponse<Unidoc.Package> = try await session.run(
            command: Mongo.Update<Mongo.Many, Unidoc.Package>.init(Self.name)
            {
                for ticket:Element in tickets
                {
                    $0
                    {
                        $0[.upsert] = true
                        $0[.q] { $0[Element[.id]] = ticket.id }
                        $0[.u]
                        {
                            $0[.setOnInsert]
                            {
                                $0[Element[.id]] = ticket.id
                                $0[Element[.time]] = ticket.time
                            }
                            $0[.set]
                            {
                                $0[Element[.node]] = ticket.node
                                $0[Element[.last]] = ticket.last
                            }
                        }
                    }
                }
            },
            against: self.database)

        return try response.updates()
    }

    public
    func find(stalest limit:Int) async throws -> [Element]
    {
        let command:Mongo.Find<Mongo.SingleBatch<Element>> = .init(Self.name,
            limit: limit)
        {
            $0[.sort] { $0[Element[.time]] = (+) }
            $0[.hint] = Self.indexTime.id
        }

        return try await session.run(command: command, against: self.database)
    }

    /// Updates the state of an existing crawling ticket.
    @discardableResult
    public
    func move(ticket:Unidoc.Package,
        time:UnixMillisecond,
        last:UnixMillisecond? = nil) async throws -> Bool?
    {
        try await self.update
        {
            $0
            {
                $0[.q] { $0[Element[.id]] = ticket }
                $0[.u]
                {
                    $0[.set]
                    {
                        //  We shouldn’t blindly store the existing `time` value into `last`,
                        //  because it might be an extreme value, like 0.
                        $0[Element[.time]] = time
                        $0[Element[.last]] = last
                    }
                }
            }
        }
    }
}
