import HTTP

extension HTTP {
    @frozen @usableFromInline enum Semicolon: HeaderWordSeparator {
        @inlinable static var character: Character { ";" }
    }
}
