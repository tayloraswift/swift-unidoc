import HTTP
import Media
import MongoQL
import SwiftinitRender
import UnidocDB
import UnidocQueries

extension Swiftinit
{
    public
    protocol MediaEndpoint:Mongo.SingleOutputEndpoint
    {
        var type:MediaType { get }
    }
}
extension Swiftinit.MediaEndpoint
    where Self:HTTP.ServerEndpoint, Query.Iteration.BatchElement == Unidoc.TextResourceOutput
{
    public consuming
    func response(as _:Swiftinit.RenderFormat) -> HTTP.ServerResponse
    {
        guard
        let output:Unidoc.TextResourceOutput = self.value
        else
        {
            return .notFound("Resource not found.")
        }

        let content:HTTP.Resource.Content
        let gzipped:Bool
        switch output.text
        {
        case .inline(.gzip(let gzip)):
            content = .binary(gzip.bytes)
            gzipped = true

        case .inline(.utf8(let utf8)):
            content = .binary(utf8)
            gzipped = false

        case .length(let bytes):
            content = .length(bytes)
            gzipped = false // ???
        }

        return .ok(.init(
            content: content,
            type: self.type,
            gzip: gzipped,
            hash: output.hash))
    }
}
