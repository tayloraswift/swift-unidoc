import HTTP
import MongoDB
import SwiftinitRender
import UnidocDB
import UnidocQueries
import UnixTime

extension Swiftinit
{
    @frozen public
    struct PackagesCrawledEndpoint:Mongo.PipelineEndpoint, Mongo.SingleBatchEndpoint
    {
        public
        let query:Unidoc.PackagesCrawledQuery
        public
        var batch:[Unidoc.PackagesCrawledQuery.Date]

        @usableFromInline
        let year:Timestamp.Year

        /// This is optional because ``Timestamp.Year`` has no guarantee of representability as
        /// a ``UnixDate``.
        @inlinable public
        init?(year:Timestamp.Year)
        {
            guard
            let range:Range<UnixDate> = .year(year)
            else
            {
                return nil
            }

            self.query = .init(during: range)
            self.batch = []
            self.year = year

        }
    }
}
extension Swiftinit.PackagesCrawledEndpoint
{
}
extension Swiftinit.PackagesCrawledEndpoint:HTTP.ServerEndpoint
{
    public consuming
    func response(as format:Swiftinit.RenderFormat) -> HTTP.ServerResponse
    {
        let page:Swiftinit.PackagesCrawledPage = .init(dates: self.batch, in: self.year)
        return .ok(page.resource(format: format))
    }
}
