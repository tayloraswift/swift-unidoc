extension SymbolGraph.Plane
{
    @frozen public
    enum Decl:SymbolGraph.PlaneType
    {
        @inlinable public static
        var plane:SymbolGraph.Plane { .decl }
    }
}
