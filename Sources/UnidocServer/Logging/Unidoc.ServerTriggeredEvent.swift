import MarkdownABI
import UnixTime

extension Unidoc {
    @frozen public struct ServerTriggeredEvent: Sendable {
        public let message: ServerLog.Message
        public let type: ServerTriggeredEventType

        @inlinable public init(message: ServerLog.Message, type: ServerTriggeredEventType) {
            self.message = message
            self.type = type
        }
    }
}
