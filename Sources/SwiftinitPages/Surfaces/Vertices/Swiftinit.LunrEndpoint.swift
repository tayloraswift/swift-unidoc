import HTTP
import Media
import MongoDB
import SwiftinitRender
import UnidocDB
import UnidocQueries
import URI

extension Swiftinit
{
    @frozen public
    struct LunrEndpoint<Collection>:Mongo.PipelineEndpoint, Mongo.SingleOutputEndpoint
        where Collection:Mongo.CollectionModel
    {
        public
        let query:SearchIndexQuery<Collection>
        public
        var value:SearchIndexQuery<Collection>.Output?

        @inlinable public
        init(query:SearchIndexQuery<Collection>)
        {
            self.query = query
            self.value = nil
        }
    }
}
extension Swiftinit.LunrEndpoint:HTTP.ServerEndpoint
{
    public consuming
    func response(as _:Swiftinit.RenderFormat) -> HTTP.ServerResponse
    {
        guard
        let output:SearchIndexQuery<Collection>.Output = self.value
        else
        {
            return .error("Query for endpoint '\(Self.self)' returned no outputs!")
        }

        let content:HTTP.Resource.Content
        switch output.json
        {
        case .binary(let utf8):     content = .binary(utf8)
        case .length(let bytes):    content = .length(bytes)
        }

        return .ok(.init(
            content: content,
            type: .application(.json, charset: .utf8),
            hash: output.hash))
    }
}
