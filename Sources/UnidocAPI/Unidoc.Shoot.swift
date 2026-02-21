import FNV1

extension Unidoc {
    @frozen public struct Shoot: Equatable, Hashable, Sendable {
        public let stem: Stem
        public let hash: FNV24?

        @inlinable public init(stem: Stem, hash: FNV24? = nil) {
            self.stem = stem
            self.hash = hash
        }
    }
}
extension Unidoc.Shoot: Comparable {
    @inlinable public static func < (lhs: Self, rhs: Self) -> Bool {
        (lhs.stem, lhs.hash?.value ?? 0) < (rhs.stem, rhs.hash?.value ?? 0)
    }
}
extension Unidoc.Shoot {
    func description(_ indent: String = "    ") -> String {
        let indent: String = .init(repeating: indent, count: max(0, self.stem.depth - 1))
        return "\(indent)\(self.stem.last)"
    }
}
extension Unidoc.Shoot: CustomDebugStringConvertible {
    public var debugDescription: String {
        self.hash.map {
            "\"\(self.stem)\" [\($0)]"
        } ?? "\"\(self.stem)\""
    }
}
