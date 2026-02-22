extension Unidoc {
    public protocol GraphLoader {
        func load(graph: GraphPath) async throws -> ArraySlice<UInt8>
    }
}
extension Unidoc.GraphLoader where Self == Unidoc.InlineLoader {
    @inlinable public static var inline: Self { .init() }
}
