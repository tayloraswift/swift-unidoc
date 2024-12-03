#if canImport(Glibc)
@preconcurrency import Glibc
#elseif canImport(Darwin)
@preconcurrency import Darwin
#endif

import HTTP
import UnidocRender

extension Unidoc
{
    public
    actor ConsoleLogger
    {
        private nonisolated
        let events:AsyncStream<LoggableEvent>.Continuation

        private
        var logs:ServerLog

        public
        init(events:AsyncStream<LoggableEvent>.Continuation)
        {
            self.events = events
            self.logs = .init(limit: 100)
        }
    }
}
extension Unidoc.ConsoleLogger
{
    public
    static func print(_ message:String)
    {
        Swift.print(message)
        fflush(stdout)
    }
}
extension Unidoc.ConsoleLogger:Unidoc.ServerLogger
{
    public nonisolated
    func log(_ event:Unidoc.ServerTriggeredEvent)
    {
        self.events.yield(.server(event))
    }
    public nonisolated
    func log(_ event:Unidoc.ClientTriggeredEvent)
    {
    }

    public
    func handle(_ event:Unidoc.ServerTriggeredEvent)
    {
        switch event.type
        {
        case .global(let level):
            //  This is a poor rendered description, as the `<dl>` contents will be rendered
            //  with no separators or line breaks, but it’s the best we can do for now.
            Self.print("\(level): \(event.message.bytecode.safe)")

        case .plugin:
            self.logs.push(event)
        }
    }
    public
    func handle(_ event:Unidoc.ClientTriggeredEvent)
    {
    }

    public
    func dashboard(from server:Unidoc.Server,
        as format:Unidoc.RenderFormat) async -> HTTP.Resource
    {
        "No logging enabled\n"
    }

    public
    subscript(plugin id:String) -> [Unidoc.ServerLog.Message]
    {
        self.logs.plugin[id]?.copy() ?? []
    }
}
