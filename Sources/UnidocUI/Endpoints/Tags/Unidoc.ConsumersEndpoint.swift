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
    struct ConsumersEndpoint
    {
        public
        let query:ConsumersQuery
        public
        var value:ConsumersQuery.Output?

        @inlinable public
        init(query:ConsumersQuery)
        {
            self.query = query
            self.value = nil
        }
    }
}
extension Unidoc.ConsumersEndpoint
{
    static
    subscript(package:Symbol.Package, page index:Int) -> URI
    {
        var uri:URI = Unidoc.ServerRoot.consumers / "\(package)"
        uri["page"] = "\(index)"
        return uri
    }
}
extension Unidoc.ConsumersEndpoint:Mongo.PipelineEndpoint, Mongo.SingleOutputEndpoint
{
    @inlinable public static
    var replica:Mongo.ReadPreference { .nearest }
}
extension Unidoc.ConsumersEndpoint:HTTP.ServerEndpoint
{
    public consuming
    func response(as format:Unidoc.RenderFormat) -> HTTP.ServerResponse
    {
        guard
        let output:Unidoc.ConsumersQuery.Output = self.value
        else
        {
            return .error("Query for endpoint '\(Self.self)' returned no outputs!")
        }

        let content:Unidoc.Paginated<Unidoc.ConsumersTable> = .init(
            table: .init(package: output.package.symbol, rows: output.list),
            index: self.query.page,
            truncated: output.list.count >= self.query.limit)

        let consumersPage:Unidoc.PackageCursorPage<Unidoc.ConsumersTable> = .init(
            location: Self[content.table.package, page: content.index],
            package: output.package,
            content: content,
            name: "Consumers")

        return .ok(consumersPage.resource(format: format))
    }
}
