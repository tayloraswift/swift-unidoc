import HTML
import HTTP
import UnidocRender
import UnixTime

extension Unidoc
{
    public
    protocol ServerLogger:Actor
    {
        func dashboard(from server:Server, as format:Unidoc.RenderFormat) async -> HTTP.Resource

        func messages(from plugin:String) async -> [PluginMessage]

        nonisolated
        func log(response:HTTP.ServerResponse, time:Duration, for request:ServerRequest)

        nonisolated
        func log(event:any PluginEvent, date:UnixAttosecond, from plugin:String?)
    }
}
