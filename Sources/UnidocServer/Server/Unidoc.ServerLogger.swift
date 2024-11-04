import HTML
import HTTP
import UnidocRender
import UnixCalendar
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
        func log(event:any ServerEvent, type:ServerEventType, date:UnixAttosecond)
    }
}
extension Unidoc.ServerLogger
{
    @inlinable public nonisolated
    func log(event:any Unidoc.ServerEvent, from plugin:String, date:UnixAttosecond = .now())
    {
        self.log(event: event, type: .plugin(plugin), date: date)
    }
    @inlinable public nonisolated
    func log(event:any Unidoc.ServerEvent, level:HTTP.LogLevel, date:UnixAttosecond = .now())
    {
        self.log(event: event, type: .global(level), date: date)
    }
}
