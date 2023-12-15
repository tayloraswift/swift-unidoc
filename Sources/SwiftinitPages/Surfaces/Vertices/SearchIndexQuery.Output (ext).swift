import HTTP
import Media
import SwiftinitRender
import UnidocQueries
import URI

extension SearchIndexQuery.Output:HTTP.ServerResponseFactory
{
    public
    func response(as _:Swiftinit.RenderFormat) throws -> HTTP.ServerResponse
    {
        let content:HTTP.Resource.Content
        switch self.json
        {
        case .binary(let utf8):     content = .binary(utf8)
        case .length(let bytes):    content = .length(bytes)
        }

        return .ok(.init(
            content: content,
            type: .application(.json, charset: .utf8),
            hash: self.hash))
    }
}
