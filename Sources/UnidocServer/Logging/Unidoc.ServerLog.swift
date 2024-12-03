import HTTP
import UnidocRender
import UnixTime

extension Unidoc
{
    @frozen public
    struct ServerLog
    {
        private
        let limit:Int

        public private(set)
        var error:MessageBuffer
        public private(set)
        var debug:MessageBuffer
        public private(set)
        var plugin:[String: MessageBuffer]

        public
        init(limit:Int)
        {
            self.limit = limit

            self.error = .init(limit: limit)
            self.debug = .init(limit: limit)
            self.plugin = [:]
        }
    }
}
extension Unidoc.ServerLog
{
    public mutating
    func push(error:Unidoc.ServerError, date:UnixAttosecond)
    {
        self.error.push(event: error, date: date)
    }

    public mutating
    func push(_ observation:Unidoc.Observation.ServerTriggered)
    {
        switch observation.type
        {
        case .global(.debug):
            self.debug.push(event: observation.event, date: observation.date)

        case .global(.error):
            self.error.push(event: observation.event, date: observation.date)

        case .plugin(let id):
            self.plugin[id, default: .init(limit: self.limit)].push(
                event: observation.event,
                date: observation.date)
        }
    }
}
