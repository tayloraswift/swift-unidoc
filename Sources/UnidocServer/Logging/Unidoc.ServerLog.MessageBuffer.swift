import DequeModule
import HTML
import UnixCalendar
import UnixTime

extension Unidoc.ServerLog {
    @frozen public struct MessageBuffer: Sendable {
        @usableFromInline var messages: Deque<Message>
        @usableFromInline let limit: Int

        @inlinable init(limit: Int) {
            self.messages = .init(minimumCapacity: limit)
            self.limit = limit
        }
    }
}
extension Unidoc.ServerLog.MessageBuffer: RandomAccessCollection {
    @inlinable public var startIndex: Int { self.messages.startIndex }
    @inlinable public var endIndex: Int { self.messages.endIndex }

    @inlinable public subscript(index: Int) -> Unidoc.ServerLog.Message { self.messages[index] }
}
extension Unidoc.ServerLog.MessageBuffer {
    @inlinable public func copy() -> [Unidoc.ServerLog.Message] { [_].init(self.messages) }

    mutating func push(_ message: Unidoc.ServerLog.Message) {
        if  self.messages.count == self.limit {
            self.messages.removeFirst()
        }

        self.messages.append(message)
    }
}
