import HTTP
import MongoDB
import SwiftinitRender
import UnidocDB
import UnidocQueries
import UnixTime

extension Swiftinit
{
    @frozen public
    struct PackagesCreatedEndpoint:Mongo.PipelineEndpoint, Mongo.SingleBatchEndpoint
    {
        public
        let query:Unidoc.PackagesQuery<Unidoc.PackageCreated>
        public
        var batch:[Unidoc.PackageOutput]

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
extension Swiftinit.PackagesCreatedEndpoint:HTTP.ServerEndpoint
{
    public consuming
    func response(as format:Swiftinit.RenderFormat) -> HTTP.ServerResponse
    {
        //  If we access `self.batch` directly, it dispatches through the protocol witness to
        //  avoid consuming `self`, so we need to use the closure to make `self` `borrowing`
        //  which will cause the compiler to choose the stored property accessor.
        let batch:[Unidoc.PackageOutput] = { $0.batch } (self)
        //  This consumes `self` because it is accessing a stored property that witnesses no
        //  protocol requirements.
        let date:Timestamp.Date = self.date
        let page:Swiftinit.PackagesCreatedPage = .init(batch, on: date)

        return .ok(page.resource(format: format))
    }
}
