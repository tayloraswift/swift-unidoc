extension Unidoc {
    @frozen public struct GraphPath {
        public let edition: Unidoc.Edition
        public let type: Unidoc.GraphType

        @inlinable public init(edition: Unidoc.Edition, type: Unidoc.GraphType) {
            self.edition = edition
            self.type = type
        }
    }
}
extension Unidoc.GraphPath {
    /// Same as ``description``, but with no leading slash.
    @inlinable public var prefix: String {
        """
        graphs/\
        \(String.init(self.edition.package.bits, radix: 16))/\
        \(String.init(self.edition.version.bits, radix: 16)).\(self.type)
        """
    }
}
extension Unidoc.GraphPath: CustomStringConvertible {
    @inlinable public var description: String { "/\(self.prefix)" }
}
