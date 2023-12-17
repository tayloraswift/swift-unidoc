import HTTP
import JSON
import Media
import SwiftinitRender
import UnidocQueries
import UnidocRecords

extension Unidoc.PackageQuery.Output:HTTP.ServerResponseFactory
{
    public consuming
    func response(as format:Swiftinit.RenderFormat) -> HTTP.ServerResponse
    {
        switch format.accept
        {
        case .application(.json):
            guard
            let status:Unidoc.PackageStatus = .init(from: self)
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
            let page:Swiftinit.TagsPage = .init(from: self)
            return .ok(page.resource(format: format))
        }
    }
}
