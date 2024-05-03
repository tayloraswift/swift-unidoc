import UnidocDB
import MongoDB

extension Unidoc
{
    public
    protocol CollectionVisitor
    {
        associatedtype Event:CollectionEvent

        static
        var title:String { get }

        mutating
        func tour(in unidoc:Unidoc.DB, with session:Mongo.Session) async throws

        mutating
        func publish(event:Event)

        func publish()
    }
}
extension Unidoc.CollectionVisitor
{
    public mutating
    func watch(db unidoc:Unidoc.DB, with pool:Mongo.SessionPool) async throws
    {
        //  Otherwise the page will be empty until something is queued.
        self.publish()

        while true
        {
            //  If we caught an error, it was probably because mongod is restarting.
            //  We should wait a little while for it to come back online.
            async
            let cooldown:Void = Task.sleep(for: .seconds(5))

            do
            {
                let session:Mongo.Session = try await .init(from: pool)
                try await self.tour(in: unidoc, with: session)
            }
            catch let error
            {
                self.publish(event: .caught(error))
            }

            try await cooldown
        }
    }
}
