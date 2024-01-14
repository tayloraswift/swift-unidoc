import DequeModule
import UnixTime

extension Swiftinit
{
    struct EventBuffer<Event> where Event:Sendable
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
extension Swiftinit.EventBuffer
{
    struct Entry:Sendable
    {
        let timestamp:Timestamp.Components
        let event:Event

        init(timestamp:Timestamp.Components, event:Event)
        {
            self.timestamp = timestamp
            self.event = event
        }
    }
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

        let now:UnixInstant = .now()
        if  let timestamp:Timestamp.Components = now.timestamp?.components
        {
            self.entries.append(.init(timestamp: timestamp,
                event: event))
        }
        else
        {
            //  Something is seriously wrong with the system clock, but we still want
            //  the logging to work. Especially if the system clock is broken.
            self.entries.append(.init(timestamp: .init(date: .init(year: 0)),
                event: event))
        }
    }
}
