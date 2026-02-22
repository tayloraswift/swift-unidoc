import FNV1

extension FNV24 {
    @inlinable public static func decl(_ symbol: Symbol.Decl.Vector) -> Self {
        .init(truncating: .decl(symbol))
    }

    @inlinable public static func decl(_ symbol: Symbol.Decl) -> Self {
        .init(truncating: .decl(symbol))
    }
}
