extension SymbolGraph.Plane
{
    @frozen public
    enum Foreign:SymbolGraph.PlaneType
    {
        @inlinable public static
        var plane:SymbolGraph.Plane { .foreign }
    }
}
