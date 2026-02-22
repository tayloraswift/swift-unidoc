@frozen public struct SourceLocation<File> {
    public var position: SourcePosition
    public var file: File

    @inlinable public init(position: SourcePosition, file: File) {
        self.position = position
        self.file = file
    }
}
extension SourceLocation: Equatable where File: Equatable {
}
extension SourceLocation: Hashable where File: Hashable {
}
extension SourceLocation: Sendable where File: Sendable {
}
extension SourceLocation: Comparable where File: Comparable {
    @inlinable public static func < (lhs: Self, rhs: Self) -> Bool {
        (lhs.file, lhs.position) < (rhs.file, rhs.position)
    }
}
extension SourceLocation<Int32>: RawRepresentable {
    @inlinable public var rawValue: Int64 {
        .init(self.file) << 32 | .init(self.position.bits)
    }
    @inlinable public init(rawValue: Int64) {
        self.init(
            position: .init(bits: .init(truncatingIfNeeded: rawValue)),
            file: .init(truncatingIfNeeded: rawValue >> 32)
        )
    }
}
extension SourceLocation {
    /// Adds the line and column components of the specified source position
    /// to this source location, if it can be represented exactly. This is
    /// useful for computing the absolute location of things within text
    /// embedded within a larger document, such as a markdown comment within
    /// a source code file.
    @inlinable public func translated(by position: SourcePosition, indent: Int = 0) -> Self? {
        if  let position: SourcePosition = .init(
                line: self.position.line + position.line,
                column: self.position.column + position.column + indent
            ) {
            .init(position: position, file: self.file)
        } else {
            nil
        }
    }

    @inlinable public func map<T>(
        _ transform: (File) throws -> T
    ) rethrows -> SourceLocation<T> {
        .init(position: self.position, file: try transform(self.file))
    }
}
extension SourceLocation: CustomStringConvertible where File: CustomStringConvertible {
    public var description: String {
        "\(self.file):\(self.position)"
    }
}
