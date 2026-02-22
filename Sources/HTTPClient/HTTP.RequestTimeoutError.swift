import HTTP

extension HTTP {
    @frozen public struct RequestTimeoutError: Equatable, Error, Sendable {
        @inlinable public init() {
        }
    }
}
