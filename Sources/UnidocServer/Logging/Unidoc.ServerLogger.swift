import HTTPServer
import MarkdownABI
import UnidocRender
import UnixCalendar
import UnixTime

extension Unidoc
{
    public
    protocol ServerLogger:Actor
    {
        init(events:AsyncStream<LoggableEvent>.Continuation)

        nonisolated
        func log(_ event:ClientTriggeredEvent)
        nonisolated
        func log(_ event:ServerTriggeredEvent)

        func handle(_ event:ClientTriggeredEvent)
        func handle(_ event:ServerTriggeredEvent)

        func dashboard(from server:Server, as format:Unidoc.RenderFormat) async -> HTTP.Resource

        subscript(plugin id:String) -> [ServerLog.Message] { get }
    }
}
extension Unidoc.ServerLogger
{
    @inlinable nonisolated
    func log(
        as type:Unidoc.ServerTriggeredEventType,
        at date:UnixAttosecond,
        encode:(inout Markdown.BinaryEncoder) -> ())
    {
        self.log(.init(message: .init(bytecode: .init(with: encode), date: date), type: type))
    }

    @inlinable nonisolated
    func log(
        as type:Unidoc.ServerTriggeredEventType,
        at date:UnixAttosecond,
        reflecting error:any Error)
    {
        self.log(as: type, at: date)
        {
            $0[.dl]
            {
                $0[.dt] = "Error type"
                $0[.dd] = String.init(reflecting: Swift.type(of: error))
            }

            $0[.pre] = String.init(reflecting: error)
        }
    }
}
extension Unidoc.ServerLogger
{
    @inlinable public nonisolated
    func log(
        as level:Unidoc.ServerLog.Level,
        at date:UnixAttosecond = .now(),
        encode:(inout Markdown.BinaryEncoder) -> ())
    {
        self.log(as: .global(level), at: date, encode: encode)
    }

    @inlinable public nonisolated
    func log(error:any Error,
        file:String = #fileID,
        line:Int = #line,
        at date:UnixAttosecond = .now())
    {
        self.log(as: .global(.error), at: date)
        {
            $0[.dl]
            {
                $0[.dt] = "Error type"
                $0[.dd] = String.init(reflecting: Swift.type(of: error))

                $0[.dt] = "Caught at"
                $0[.dd] = "\(file):\(line)"
            }

            $0[.pre] = String.init(reflecting: error)
        }
    }
}
extension Unidoc.ServerLogger
{
    @inlinable public
    static func run<T>(with body:(Self) async throws -> T) async -> T?
    {
        let events:AsyncStream<Unidoc.LoggableEvent>.Continuation
        let stream:AsyncStream<Unidoc.LoggableEvent>

        (stream, events) = AsyncStream<Unidoc.LoggableEvent>.makeStream()

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
    func listen(to stream:AsyncStream<Unidoc.LoggableEvent>) async
    {
        for await event:Unidoc.LoggableEvent in stream
        {
            switch event
            {
            case .client(let event):  self.handle(event)
            case .server(let event):  self.handle(event)
            }
        }
    }
}
