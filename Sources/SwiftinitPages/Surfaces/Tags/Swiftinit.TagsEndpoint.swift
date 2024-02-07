import HTTP
import JSON
import Media
import MongoDB
import SwiftinitRender
import UnidocDB
import UnidocQueries
import UnidocRecords

extension Swiftinit
{
    @frozen public
    struct TagsEndpoint
    {
        public
        let query:Unidoc.VersionsQuery
        public
        var value:Unidoc.VersionsQuery.Output?

        @inlinable public
        init(query:Unidoc.VersionsQuery)
        {
            self.query = query
            self.value = nil
        }
    }
}
extension Swiftinit.TagsEndpoint:Mongo.PipelineEndpoint, Mongo.SingleOutputEndpoint
{
    @inlinable public static
    var replica:Mongo.ReadPreference { .nearest }
}
extension Swiftinit.TagsEndpoint:HTTP.ServerEndpoint
{
    public consuming
    func response(as format:Swiftinit.RenderFormat) -> HTTP.ServerResponse
    {
        guard
        let output:Unidoc.VersionsQuery.Output = self.value
        else
        {
            return .error("Query for endpoint '\(Self.self)' returned no outputs!")
        }

        switch format.accept
        {
        case .application(.json):
            guard
            let status:Unidoc.PackageStatus = .init(from: output)
            else
            {
                return .notFound(.init(content: .string(""),
                    type: .text(.plain, charset: .utf8)))
            }

            let json:JSON = .object(with: status.encode(to:))

            return .ok(.init(
                content: .binary(json.utf8),
                type: .application(.json, charset: .utf8)))

        case _:
            let page:Swiftinit.TagsPage = .init(from: output)
            return .ok(page.resource(format: format))
        }
    }
}
