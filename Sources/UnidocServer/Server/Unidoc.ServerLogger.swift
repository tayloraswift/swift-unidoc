import HTTP
import UnidocRender

extension Unidoc
{
    public
    protocol ServerLogger:AnyActor
    {
        func dashboard(from server:Server, as format:Unidoc.RenderFormat) async -> HTTP.Resource

        nonisolated
        func log(request:IncomingRequest, with response:HTTP.ServerResponse, time:Duration)

        nonisolated
        func log(request:IncomingRequest, with error:any Error)
    }
}
