import HTTP
import Media
import MongoQL
import SwiftinitRender
import UnidocDB
import UnidocQueries

extension Swiftinit
{
    public
    typealias MediaEndpoint = _SwiftinitMediaEndpoint
}
public
protocol _SwiftinitMediaEndpoint:Mongo.SingleOutputEndpoint
{
    var type:MediaType { get }
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
        switch output.utf8
        {
        case .binary(let utf8):     content = .binary(utf8)
        case .length(let bytes):    content = .length(bytes)
        }

        return .ok(.init(
            content: content,
            type: self.type,
            hash: output.hash))
    }
}
