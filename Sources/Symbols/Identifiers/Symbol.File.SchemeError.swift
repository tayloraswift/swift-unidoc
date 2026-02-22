extension Symbol.File {
    @frozen public struct SchemeError: Equatable, Error {
        public let uri: String

        @inlinable public init(uri: String) {
            self.uri = uri
        }
    }
}
extension Symbol.File.SchemeError: CustomStringConvertible {
    public var description: String {
        "uri '\(self.uri)' does not begin with 'file://'"
    }
}
