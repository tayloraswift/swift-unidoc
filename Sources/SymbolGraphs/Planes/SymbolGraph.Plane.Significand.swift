extension SymbolGraph.Plane {
    @frozen public enum Significand: Hashable, Equatable, Sendable {
        case significand
    }
}
extension SymbolGraph.Plane.Significand {
    @inlinable public static func & (scalar: Int32, self: Self) -> Int32 {
        scalar & 0x00_FFFFFF
    }
}
