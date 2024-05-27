import HTTP
import MongoDB
import UnidocRender
import UnidocDB
import UnidocQueries
import UnixTime
import URI

extension Unidoc
{
    @frozen public
    struct PackagesCreatedEndpoint
    {
        public
        let query:PackagesQuery<PackageCreated>
        public
        var batch:[EditionOutput]

        @usableFromInline
        let date:Timestamp.Date

        @inlinable public
        init?(date:Timestamp.Date)
        {
            guard
            let start:UnixDate = .init(utc: date)
            else
            {
                return nil
            }

            self.query = .init(during: start ..< start.advanced(by: 1), limit: 100)
            self.batch = []
            self.date = date
        }
    }
}
extension Unidoc.PackagesCreatedEndpoint
{
    static
    subscript(date:Timestamp.Date) -> URI { Unidoc.ServerRoot.telescope / "\(date)" }
}
extension Unidoc.PackagesCreatedEndpoint:Mongo.PipelineEndpoint, Mongo.SingleBatchEndpoint
{
    @inlinable public static
    var replica:Mongo.ReadPreference { .nearest }
}
extension Unidoc.PackagesCreatedEndpoint:HTTP.ServerEndpoint
{
    public consuming
    func response(as format:Unidoc.RenderFormat) -> HTTP.ServerResponse
    {
        //  If we access `self.batch` directly, it dispatches through the protocol witness to
        //  avoid consuming `self`, so we need to use the closure to make `self` `borrowing`
        //  which will cause the compiler to choose the stored property accessor.
        let batch:[Unidoc.EditionOutput] = { $0.batch } (self)
        //  This consumes `self` because it is accessing a stored property that witnesses no
        //  protocol requirements.
        let date:Timestamp.Date = self.date
        let page:Unidoc.PackagesCreatedPage = .init(
            groups: .init(organizing: batch),
            date: date)

        return .ok(page.resource(format: format))
    }
}
