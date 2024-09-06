import HTTP
import MongoDB
import Symbols
import UnidocDB
import UnidocQueries
import UnidocRender
import URI

extension Unidoc
{
    @frozen public
    struct CompleteBuildsEndpoint
    {
        public
        let query:CompleteBuildsQuery
        public
        var value:CompleteBuildsQuery.Output?

        @inlinable public
        init(query:CompleteBuildsQuery)
        {
            self.query = query
            self.value = nil
        }
    }
}
extension Unidoc.CompleteBuildsEndpoint
{
    static
    subscript(package:Symbol.Package, page index:Int) -> URI
    {
        var uri:URI = Unidoc.ServerRoot.runs / "\(package)"
        uri["page"] = "\(index)"
        return uri
    }
}
extension Unidoc.CompleteBuildsEndpoint:Mongo.PipelineEndpoint, Mongo.SingleOutputEndpoint
{
    @inlinable public static
    var replica:Mongo.ReadPreference { .nearest }
}
extension Unidoc.CompleteBuildsEndpoint:HTTP.ServerEndpoint
{
    public consuming
    func response(as format:Unidoc.RenderFormat) -> HTTP.ServerResponse
    {
        guard
        let output:Unidoc.CompleteBuildsQuery.Output = self.value
        else
        {
            return .error("Query for endpoint '\(Self.self)' returned no outputs!")
        }

        let view:Unidoc.Permissions = format.security.permissions(package: output.package,
            user: output.user)

        let content:Unidoc.Paginated<Unidoc.CompleteBuildsTable> = .init(
            table: .init(
                package: output.package.symbol,
                rows: output.list,
                view: view),
            index: self.query.page,
            truncated: output.list.count >= self.query.limit)

        let completeBuildsPage:Unidoc.PackageCursorPage<Unidoc.CompleteBuildsTable> = .init(
            location: Self[content.table.package, page: content.index],
            package: output.package,
            content: content,
            name: "Runs")

        return .ok(completeBuildsPage.resource(format: format))
    }
}
