extension HTTP {
    enum StreamIdentifierError: Error, Sendable {
        case missing
    }
}
extension HTTP.StreamIdentifierError: CustomStringConvertible {
    var description: String {
        switch self {
        case .missing:  "Missing stream identifier"
        }
    }
}
