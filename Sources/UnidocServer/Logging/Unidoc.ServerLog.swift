import HTTP
import UnidocRender
import UnixTime

extension Unidoc {
    @frozen public struct ServerLog {
        private let limit: Int

        public private(set) var error: MessageBuffer
        public private(set) var debug: MessageBuffer
        public private(set) var plugin: [String: MessageBuffer]

        public init(limit: Int) {
            self.limit = limit

            self.error = .init(limit: limit)
            self.debug = .init(limit: limit)
            self.plugin = [:]
        }
    }
}
extension Unidoc.ServerLog {
    public mutating func push(message: Message, to log: Unidoc.ServerLog.Level) {
        switch log {
        case .debug:    self.debug.push(message)
        case .error:    self.error.push(message)
        }
    }

    public mutating func push(_ event: Unidoc.ServerTriggeredEvent) {
        switch event.type {
        case .global(let log):
            self.push(message: event.message, to: log)

        case .plugin(let id):
            self.plugin[id, default: .init(limit: self.limit)].push(event.message)
        }
    }
}
