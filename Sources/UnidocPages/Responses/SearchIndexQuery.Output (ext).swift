import HTTP
import Media
import UnidocQueries
import URI

extension SearchIndexQuery.Output:ServerResponseFactory
{
    public
    func response(as _:AcceptType?) throws -> ServerResponse
    {
        let content:ServerResource.Content
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
