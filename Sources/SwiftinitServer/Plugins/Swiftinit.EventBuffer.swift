import DequeModule
import UnixTime

extension Swiftinit
{
    struct EventBuffer<Event>
    {
        private(set)
        var entries:Deque<Entry>
        private
        let limit:Int

        init(minimumCapacity limit:Int)
        {
            self.entries = .init(minimumCapacity: limit)
            self.limit = limit
        }
    }
}
extension Swiftinit.EventBuffer:Sendable where Event:Sendable
{
}
extension Swiftinit.EventBuffer
{
    mutating
    func push(event:Event)
    {
        if  self.entries.count == self.limit
        {
            self.entries.removeFirst()
        }

        self.entries.append(.init(pushed: .now(), event: event))
    }
}
