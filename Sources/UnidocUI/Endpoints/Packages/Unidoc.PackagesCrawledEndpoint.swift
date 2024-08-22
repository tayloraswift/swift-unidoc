import HTTP
import MongoDB
import UnidocDB
import UnidocQueries
import UnidocRender
import UnixCalendar
import UnixTime
import URI

extension Unidoc
{
    @frozen public
    struct PackagesCrawledEndpoint
    {
        public
        let query:PackagesCrawledQuery
        public
        var batch:[PackagesCrawledQuery.Date]

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
extension Unidoc.PackagesCrawledEndpoint
{
    static
    subscript(year:Timestamp.Year) -> URI { Unidoc.ServerRoot.telescope / "\(year)" }
}
extension Unidoc.PackagesCrawledEndpoint:Mongo.PipelineEndpoint, Mongo.SingleBatchEndpoint
{
    @inlinable public static
    var replica:Mongo.ReadPreference { .nearest }
}
extension Unidoc.PackagesCrawledEndpoint:HTTP.ServerEndpoint
{
    public consuming
    func response(as format:Unidoc.RenderFormat) -> HTTP.ServerResponse
    {
        let page:Unidoc.PackagesCrawledPage = .init(dates: self.batch, in: self.year)
        return .ok(page.resource(format: format))
    }
}
