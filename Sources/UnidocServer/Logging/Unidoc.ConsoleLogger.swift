import HTTP
import UnidocRender

extension Unidoc
{
    public
    actor ConsoleLogger
    {
        private nonisolated
        let events:AsyncStream<Observation>.Continuation

        private
        var logs:ServerLog

        public
        init(events:AsyncStream<Observation>.Continuation)
        {
            self.events = events
            self.logs = .init(limit: 100)
        }
    }
}
extension Unidoc.ConsoleLogger:Unidoc.ServerLogger
{
    public nonisolated
    func log(_ observation:Unidoc.Observation.ServerTriggered)
    {
        self.events.yield(.server(observation))
    }
    public nonisolated
    func log(_ observation:Unidoc.Observation.ClientTriggered)
    {
    }

    public
    func handle(_ observation:Unidoc.Observation.ServerTriggered)
    {
        self.logs.push(observation)
    }
    public
    func handle(_ observation:Unidoc.Observation.ClientTriggered)
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
