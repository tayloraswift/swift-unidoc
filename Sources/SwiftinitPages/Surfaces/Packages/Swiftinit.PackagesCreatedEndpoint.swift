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
        let query:Unidoc.PackagesCreatedQuery
        public
        var batch:[Unidoc.PackageMetadata]

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
extension Swiftinit.PackagesCreatedEndpoint
{
}
extension Swiftinit.PackagesCreatedEndpoint:HTTP.ServerEndpoint
{
    public consuming
    func response(as format:Swiftinit.RenderFormat) -> HTTP.ServerResponse
    {
        let page:Swiftinit.PackagesCreatedPage = .init(packages: self.batch, on: self.date)
        return .ok(page.resource(format: format))
    }
}
