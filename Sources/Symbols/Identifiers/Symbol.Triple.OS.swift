extension Symbol.Triple {
    @frozen public struct OS: Equatable, Hashable, Sendable {
        public let name: String

        @inlinable init(name: String) {
            self.name = name
        }
    }
}
extension Symbol.Triple.OS: ExpressibleByStringLiteral {
    @inlinable public init(stringLiteral: String) { self.init(name: stringLiteral) }
}
extension Symbol.Triple.OS: CustomStringConvertible {
    @inlinable public var description: String { self.name }
}
extension Symbol.Triple.OS {
    @inlinable public static var linux: Self { "linux" }

    @inlinable public static var macosx14_0: Self { "macosx14.0" }

    @inlinable public static var macosx15_0: Self { "macosx15.0" }
}
