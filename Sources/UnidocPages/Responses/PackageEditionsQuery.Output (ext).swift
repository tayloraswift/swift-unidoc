import HTTP
import JSON
import Media
import UnidocAutomation
import UnidocQueries
import URI

extension PackageEditionsQuery.Output:ServerResponseFactory
{
    public
    func response(with assets:StaticAssets, as type:AcceptType?) throws -> ServerResponse
    {
        switch type
        {
        case .application(.json):
            guard
            let status:PackageBuildStatus = .init(from: self)
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
            let list:Site.Tags.List = .init(from: self)
            return .ok(list.resource(assets: assets))
        }
    }
}
