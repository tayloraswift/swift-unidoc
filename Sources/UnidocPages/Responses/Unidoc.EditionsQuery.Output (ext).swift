import HTTP
import JSON
import Media
import UnidocQueries
import UnidocRecords

extension Unidoc.EditionsQuery.Output:HTTP.ServerResponseFactory
{
    public
    func response(as format:Unidoc.RenderFormat) -> HTTP.ServerResponse
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
            let page:Unidoc.EditionsPage = .init(from: self)
            return .ok(page.resource(format: format))
        }
    }
}
