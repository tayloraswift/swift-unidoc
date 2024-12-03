import HTTP
import UnidocRender
import UnixCalendar
import UnixTime

extension Unidoc
{
    public
    protocol ServerLogger:Actor
    {
        init(events:AsyncStream<Observation>.Continuation)

        nonisolated
        func log(_ observation:Observation.ClientTriggered)
        nonisolated
        func log(_ observation:Observation.ServerTriggered)

        func handle(_ observation:Observation.ClientTriggered)
        func handle(_ observation:Observation.ServerTriggered)

        func dashboard(from server:Server, as format:Unidoc.RenderFormat) async -> HTTP.Resource

        subscript(plugin id:String) -> [ServerLog.Message] { get }
    }
}
extension Unidoc.ServerLogger
{
    @inlinable public nonisolated
    func log(event:any Unidoc.ServerEvent, from plugin:String, date:UnixAttosecond = .now())
    {
        self.log(.init(event: event, type: .plugin(plugin), date: date))
    }
    @inlinable public nonisolated
    func log(event:any Unidoc.ServerEvent, level:HTTP.LogLevel, date:UnixAttosecond = .now())
    {
        self.log(.init(event: event, type: .global(level), date: date))
    }
}
extension Unidoc.ServerLogger
{
    @inlinable public
    static func run<T>(with body:(Self) async throws -> T) async -> T?
    {
        let events:AsyncStream<Unidoc.Observation>.Continuation
        let stream:AsyncStream<Unidoc.Observation>

        (stream, events) = AsyncStream<Unidoc.Observation>.makeStream()

        let loop:Self = .init(events: events)

        async
        let _:Void = loop.listen(to: stream)

        do
        {
            return try await body(loop)
        }
        catch let error
        {
            //  It would not make sense to log this error, because the application is already
            //  shutting down.
            print("(top-level) \(error)")
            return nil
        }
    }

    @inlinable
    func listen(to stream:AsyncStream<Unidoc.Observation>) async
    {
        for await observation:Unidoc.Observation in stream
        {
            switch observation
            {
            case .client(let observation):  self.handle(observation)
            case .server(let observation):  self.handle(observation)
            }
        }
    }
}
