extension SymbolGraph {
    @frozen public enum DeclPlane: SymbolGraph.PlaneType {
        @inlinable public static var plane: SymbolGraph.Plane { .decl }
    }
}
