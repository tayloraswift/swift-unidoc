import HTTP

extension Unidoc {
    @frozen public enum ServerTriggeredEventType: Sendable {
        case global(ServerLog.Level)
        case plugin(String)
    }
}
