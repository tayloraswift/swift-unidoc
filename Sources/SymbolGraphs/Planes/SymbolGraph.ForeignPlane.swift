extension SymbolGraph
{
    @frozen public
    enum ForeignPlane:SymbolGraph.PlaneType
    {
        @inlinable public static
        var plane:SymbolGraph.Plane { .foreign }
    }
}
