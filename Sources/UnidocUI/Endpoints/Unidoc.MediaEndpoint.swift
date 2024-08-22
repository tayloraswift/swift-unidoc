import HTTP
import Media
import MongoQL
import UnidocDB
import UnidocQueries
import UnidocRender

extension Unidoc
{
    public
    protocol MediaEndpoint:Mongo.SingleOutputEndpoint
    {
        var type:MediaType { get }
    }
}
extension Unidoc.MediaEndpoint
    where Self:HTTP.ServerEndpoint, Query.Iteration.BatchElement == Unidoc.TextResourceOutput
{
    public consuming
    func response(as _:Unidoc.RenderFormat) -> HTTP.ServerResponse
    {
        guard
        let output:Unidoc.TextResourceOutput = self.value
        else
        {
            return .notFound("Resource not found.")
        }

        let content:HTTP.Resource.Content?

        switch output.text
        {
        case .inline(.gzip(let gzip)):
            content = .init(body: .binary(gzip.bytes), type: self.type, encoding: .gzip)

        case .inline(.utf8(let utf8)):
            content = .init(body: .binary(utf8), type: self.type)

        case .length:
            content = nil
        }

        return .ok(.init(content: content, hash: output.hash))
    }
}
